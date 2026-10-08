import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/services/local_marketplace_store.dart';
import 'package:takimaki_full/utils/public_name.dart';
import 'package:takimaki_full/data/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'customer_first_name': 'Tímea',
      'customer_last_name': 'Boka',
      'provider_first_name': 'Anna Mária',
      'provider_last_name': 'Kiss',
      'provider_services': jsonEncode([
        {'name': 'Általános takarítás'},
      ]),
    }),
  );
  Future<String> request([String service = 'Általános takarítás']) =>
      LocalMarketplaceStore.createRequest(
        service: service,
        address: 'Budapest',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        note: '',
        laundryAndIroning: false,
      );

  test(
    'Own request is hidden and direct send is blocked across roles',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_phone', 'same-account');
      final id = await request();
      final saved =
          (jsonDecode(prefs.getString('provider_requests')!) as List).single;
      expect(await LocalMarketplaceStore.providerRequests(), isEmpty);
      expect(
        await LocalMarketplaceStore.offerBlockReason(
          Map<String, dynamic>.from(saved),
        ),
        contains('saját'),
      );
      await expectLater(
        LocalMarketplaceStore.sendOffer(
          request: Map<String, dynamic>.from(saved),
          price: 12000,
          note: '',
          providerName: 'Más név',
        ),
        throwsStateError,
      );
      expect(await LocalMarketplaceStore.offersFor(id), isEmpty);
      await prefs.setString('registration_phone', 'other-account');
      expect(await LocalMarketplaceStore.providerRequests(), hasLength(1));
    },
  );

  test(
    'Stored own offer cannot be accepted even with forged incoming identity',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_phone', 'same-account');
      final id = await request();
      final offer = {
        'id': 'self-offer',
        'request_id': id,
        'provider_id': 'same-account',
        'status': 'pending',
        'price': 12000,
      };
      await prefs.setString('customer_offers', jsonEncode([offer]));
      await expectLater(
        LocalMarketplaceStore.acceptOffer({...offer, 'provider_id': 'forged'}),
        throwsStateError,
      );
      expect(
        (await LocalMarketplaceStore.offersFor(id)).single['status'],
        'pending',
      );
      expect(await LocalMarketplaceStore.providerOrders(), isEmpty);
    },
  );

  test('Legacy demo jobs do not consume the first real provider job', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LocalMarketplaceStore.providerFirstAcceptedKey, true);
    await prefs.setString(
      'provider_orders',
      jsonEncode([
        {'id': 'TEST123A'},
      ]),
    );
    expect(await LocalMarketplaceStore.canProviderSendOffer(), isTrue);
    await prefs.setBool(LocalMarketplaceStore.providerFirstAcceptedKey, true);
    await prefs.setString(
      'provider_orders',
      jsonEncode([
        {'id': 'REAL123'},
      ]),
    );
    expect(await LocalMarketplaceStore.canProviderSendOffer(), isFalse);
  });

  test(
    'Only matching open requests; no unrelated, accepted or expired work',
    () async {
      final id = await request();
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await request('Villanyszerelés');
      var visible = await LocalMarketplaceStore.providerRequests();
      expect(visible.map((item) => item['id']), [id]);
      await LocalMarketplaceStore.updateRequestStatus(id, 'accepted');
      expect(await LocalMarketplaceStore.providerRequests(), isEmpty);
      await LocalMarketplaceStore.updateRequestStatus(id, 'pending');
      final prefs = await SharedPreferences.getInstance();
      final records = jsonDecode(prefs.getString('provider_requests')!) as List;
      for (final item in records) {
        item['created_at'] =
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      }
      await prefs.setString('provider_requests', jsonEncode(records));
      expect(await LocalMarketplaceStore.providerRequests(), isEmpty);
    },
  );

  test(
      'Apartment request is shown only to providers with every requested capability',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'provider_services',
      jsonEncode([
        {
          'name': 'Apartmantakarítás',
          'service_options': ['Mosodai szolgáltatás', 'Helyszíni mosás'],
          'price_rules': [
            {'label': 'Apartmantakarítás'},
            {'label': 'Mosás'},
            {'label': 'Vasalás'},
          ],
        },
      ]),
    );
    final matchingId = await LocalMarketplaceStore.createRequest(
      service: 'Apartmantakarítás',
      address: 'Budapest',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      note: '',
      laundryAndIroning: true,
      serviceOptions: const ['Mosodai szolgáltatás', 'Mosás', 'Vasalás'],
    );
    await LocalMarketplaceStore.createRequest(
      service: 'Apartmantakarítás',
      address: 'Budapest',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      note: '',
      laundryAndIroning: true,
      serviceOptions: const [
        'Mosodai szolgáltatás',
        'Helyszíni mosás',
        'Mosás',
        'Vasalás',
        'Ágyneműmosás',
      ],
    );
    final visible = await LocalMarketplaceStore.providerRequests();
    expect(visible.map((item) => item['id']), [matchingId]);
  });

  test(
    'Matching service sends offer, customer accepts, job leaves new requests',
    () async {
      final id = await request();
      final item = (await LocalMarketplaceStore.providerRequests()).single;
      expect(await LocalMarketplaceStore.offersFor(id), isEmpty);
      await LocalMarketplaceStore.sendOffer(
        request: item,
        price: 12000,
        note: 'Vállalom',
      );
      var offers = await LocalMarketplaceStore.offersFor(id);
      expect(offers.single['price'], 12000);
      expect(peerNameFor(offers.single, 'provider'), 'Anna Mária');
      expect(peerNameFor(item, 'customer'), 'Tímea');
      await LocalMarketplaceStore.sendOffer(
        request: item,
        price: 13000,
        note: 'Módosítva',
      );
      offers = await LocalMarketplaceStore.offersFor(id);
      expect(offers, hasLength(1));
      expect(offers.single['price'], 13000);
      await LocalMarketplaceStore.acceptOffer(offers.single);
      expect(await LocalMarketplaceStore.providerRequests(), isEmpty);
      expect(
        (await LocalMarketplaceStore.providerOrders()).single['status'],
        'Elfogadva',
      );
      expect(
        (await LocalMarketplaceStore.customerOrders()).single['status'],
        'Elfogadva',
      );
      expect(
        () =>
            LocalMarketplaceStore.sendOffer(request: item, price: 1, note: ''),
        throwsStateError,
      );
    },
  );

  test(
      'No saved service means no unsolicited requests; a removed service blocks sending',
      () async {
    await request();
    final item = (await LocalMarketplaceStore.providerRequests()).single;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider_services', '[]');
    expect(await LocalMarketplaceStore.providerRequests(), isEmpty);
    expect(
      await LocalMarketplaceStore.offerBlockReason(item),
      contains('szolgáltatásod'),
    );
    expect(
      () =>
          LocalMarketplaceStore.sendOffer(request: item, price: 100, note: ''),
      throwsStateError,
    );
  });

  test(
    'Subscription block is explicit, activation enables the next offer',
    () async {
      await request();
      final item = (await LocalMarketplaceStore.providerRequests()).single;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LocalMarketplaceStore.providerFirstAcceptedKey, true);
      expect(
        await LocalMarketplaceStore.offerBlockReason(item),
        contains('előfizetés'),
      );
      await prefs.setBool(LocalMarketplaceStore.providerSubscriptionKey, true);
      expect(await LocalMarketplaceStore.offerBlockReason(item), isNull);
      await LocalMarketplaceStore.sendOffer(
        request: item,
        price: 100,
        note: '',
      );
    },
  );

  test(
      'Public names cover legacy records and preserve explicit compound first names',
      () {
    expect(publicName('Boka Tímea'), 'Tímea');
    expect(
      publicName('Kiss Anna Mária', firstName: 'Anna Mária'),
      'Anna Mária',
    );
    expect(publicName(null), 'Partner');
    final old = MockThread.fromJson({
      'id': 'old',
      'peerName': 'Boka Tímea',
      'messages': [],
    });
    expect(old.displayName, 'Tímea');
    final thread = MockThread(
      id: 'new',
      peerName: 'Kiss Anna Mária',
      peerFirstName: 'Anna Mária',
      messages: [],
    );
    expect(MockThread.fromJson(thread.toJson()).displayName, 'Anna Mária');
  });
}
