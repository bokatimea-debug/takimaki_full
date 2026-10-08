import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/data/mock_data.dart';
import 'package:takimaki_full/screens/chat_screens.dart';
import 'package:takimaki_full/screens/customer_edit_profile_screen.dart';
import 'package:takimaki_full/screens/customer_orders_screen.dart';
import 'package:takimaki_full/screens/customer_search_screen.dart';
import 'package:takimaki_full/widgets/service_choice_grid.dart';
import 'package:takimaki_full/screens/customer_profile_screen.dart';
import 'package:takimaki_full/screens/otp_verify_screen.dart';
import 'package:takimaki_full/screens/phone_number_screen.dart';
import 'package:takimaki_full/screens/profile_info_screen.dart';
import 'package:takimaki_full/screens/provider_add_service_screen.dart';
import 'package:takimaki_full/screens/provider_edit_profile_screen.dart';
import 'package:takimaki_full/screens/provider_profile_screen.dart';
import 'package:takimaki_full/screens/provider_services_screen.dart';
import 'package:takimaki_full/screens/registration_success_screen.dart';
import 'package:takimaki_full/screens/settings_screen.dart';
import 'package:takimaki_full/screens/subscription_screen.dart';
import 'package:takimaki_full/theme.dart';
import 'package:takimaki_full/services/account_store.dart';
import 'package:takimaki_full/widgets/branded_background.dart';

const _captureKey = ValueKey('layout-capture');
const _sizes = [(360.0, 740.0, 1.0), (412.0, 892.0, 1.0), (320.0, 640.0, 1.3)];
final _screens = <String, Widget Function()>{
  'profile_info': () => const ProfileInfoScreen(),
  'phone': () => const PhoneNumberScreen(),
  'otp': () => const OtpVerifyScreen('+36302222023'),
  'registration_success': () => const RegistrationSuccessScreen(),
  'provider_profile': () => const ProviderProfileScreen(),
  'customer_profile': () => const CustomerProfileScreen(),
  'customer_order_form': () => const CustomerSearchScreen(),
  'provider_edit': () => const ProviderEditProfileScreen(),
  'customer_edit': () => const CustomerEditProfileScreen(),
  'provider_services': () => const ProviderServicesScreen(),
  'provider_add_service': () => const ProviderAddServiceScreen(),
  'subscriptions': () => const SubscriptionScreen(),
  'chat_list': () => const ChatListScreen(),
  'chat_thread': () => const ChatThreadScreen(threadId: 'layout-chat'),
  'orders': () => const CustomerOrdersScreen(),
  'settings': () => const SettingsScreen(),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final sdk =
        Platform.environment['FLUTTER_ROOT'] ??
        '${Directory.current.parent.path}/flutter_sdk';
    final loader = FontLoader('Roboto');
    for (final name in ['Regular', 'Medium', 'Bold', 'Black']) {
      final file = File(
        '$sdk/bin/cache/artifacts/material_fonts/Roboto-$name.ttf',
      );
      if (file.existsSync())
        loader.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
    }
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'customer_first_name': 'Tímea',
      'customer_last_name': 'Boka',
      'provider_first_name': 'Tímea',
      'provider_last_name': 'Boka',
      'registration_first_name': 'Tímea',
      'registration_last_name': 'Boka',
      'registration_phone': '+36302222023',
      'provider_services': jsonEncode([
        {
          'id': 'one',
          'name': 'Apartmantakarítás',
          'price_raw': 14500,
          'price_fmt': '14 500',
          'unit': 'Ft/alkalom',
          'dates': [],
          'price_rules': [
            {'type': 'area', 'from': 0, 'to': 50, 'price': 12000, 'unit': 'Ft'},
            {
              'type': 'area',
              'from': 51,
              'to': 80,
              'price': 16000,
              'unit': 'Ft',
            },
          ],
        },
        {
          'id': 'two',
          'name': 'Mosodai szolgáltatás',
          'price_raw': 1800,
          'price_fmt': '1 800',
          'unit': 'Ft/kg',
          'dates': [],
          'price_rules': [],
        },
      ]),
    });
    MockData.threads = [
      MockThread(
        id: 'layout-chat',
        peerName: 'Nagy Petra',
        messages: [
          MockMessage(
            id: 'one',
            threadId: 'layout-chat',
            from: 'Ők',
            text: 'A holnapi időpont megfelelő.',
            ts: DateTime.now(),
          ),
        ],
      ),
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'local_chat_threads',
      jsonEncode(MockData.threads.map((thread) => thread.toJson()).toList()),
    );
  });

  for (final screen in _screens.entries) {
    for (final size in _sizes) {
      testWidgets(
        '${screen.key} has no overflow at ${size.$1}x${size.$2} scale ${size.$3}',
        (tester) async {
          await _show(
            tester,
            screen.value(),
            Size(size.$1, size.$2),
            scale: size.$3,
            canPop: [
              'provider_edit',
              'customer_edit',
              'provider_add_service',
            ].contains(screen.key),
          );
          expect(tester.takeException(), isNull);
          await _capture(tester, '${screen.key}_${size.$1.toInt()}_${size.$3}');
        },
      );
    }
  }

  for (final size in [const Size(360, 740), const Size(412, 892)]) {
    testWidgets('complete order form remains reachable ${size.width}', (
      tester,
    ) async {
      await _show(tester, const CustomerSearchScreen(), size, canPop: true);
      await tester.tap(
        find.byKey(const ValueKey('customer-service-selector')),
      );
      await tester.pumpAndSettle();
      for (final item in serviceChoices) {
        final option = find.byKey(ValueKey('service-option-${item['name']}'));
        expect(option, findsOneWidget);
      }
      await tester.tap(
        find.byKey(const ValueKey('service-option-Apartmantakarítás')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('service-option-Nagytakarítás')),
        findsNothing,
      );
      final action = _button('Ajánlatok kérése');
      expect(action.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(action).bottom,
        lessThanOrEqualTo(size.height - 36),
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'Megjegyzés (opcionális)'),
        findsOneWidget,
      );
      await _capture(tester, 'order_form_107_${size.width.toInt()}');
    });
  }

  testWidgets('first service saves general availability into profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(360, 740),
      canPop: true,
    );
    await _chooseService(tester, 'Általános takarítás');
    await _addPriceItem(tester, 'Takarítás', 'Ft/óra', '4500');
    await _reachService(tester, find.byKey(const ValueKey('general-hours-wd')));
    await tester.tap(find.byKey(const ValueKey('general-hours-wd')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _reachService(tester, find.byKey(const ValueKey('service-save')));
    await tester.tap(find.byKey(const ValueKey('service-save')));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('provider_wd_from'), '09:00');
    expect(prefs.getString('provider_wd_to'), '17:00');
    await _show(
      tester,
      const ProviderEditProfileScreen(),
      const Size(360, 740),
    );
    expect(find.textContaining('09:00'), findsOneWidget);
  });

  testWidgets('three services fit above add action', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final services = jsonDecode(prefs.getString('provider_services')!) as List;
    services.add({
      'id': 'three',
      'name': 'Általános takarítás',
      'price_raw': 3000,
      'unit': 'Ft/óra',
    });
    await prefs.setString('provider_services', jsonEncode(services));
    await _show(tester, const ProviderServicesScreen(), const Size(360, 740));
    final edits = find.byTooltip('Módosítás');
    expect(edits, findsNWidgets(3));
    _expectFullyVisible(tester, edits.last, 740);
    expect(
      tester.getRect(edits.last).bottom,
      lessThan(tester.getRect(_button('Új szolgáltatás')).top),
    );
    await _capture(tester, 'three_services_106');
  });

  testWidgets('settings keeps destructive account action reachable last', (
    tester,
  ) async {
    await _show(tester, const SettingsScreen(), const Size(360, 740));
    expect(find.text('Előfizetések'), findsOneWidget);
    final delete = _button('Profil törlése');
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    _expectFullyVisible(tester, delete, 740);
    expect(
      tester.getRect(find.text('Kijelentkezés')).top,
      lessThan(tester.getRect(delete).top),
    );
  });

  testWidgets('subscription is absent from dashboard', (tester) async {
    await _show(tester, const CustomerProfileScreen(), const Size(360, 740));
    expect(find.text('Előfizetésem'), findsNothing);
  });

  testWidgets('all service choices including new categories are reachable', (
    tester,
  ) async {
    await _show(tester, const ProviderAddServiceScreen(), const Size(360, 740));
    await tester.tap(find.byKey(const ValueKey('service-selector')));
    await tester.pumpAndSettle();
    _useLoadedTestFonts(tester);
    await tester.pumpAndSettle();
    for (final name in ['Kárpittisztítás', 'Lefolyótisztítás']) {
      final option = find.byKey(ValueKey('service-option-$name'));
      await tester.scrollUntilVisible(
        option,
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(option.hitTestable(), findsOneWidget);
    }
    await _capture(tester, 'service_picker_106');
  });

  testWidgets('service shows saved profile hours and keeps individual dates', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider_wd_from', '08:30');
    await prefs.setString('provider_wd_to', '16:30');
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(360, 740),
      canPop: true,
      arguments: {
        'id': 'one',
        'name': 'Apartmantakarítás',
        'price_raw': 4500,
        'unit': 'Ft/óra',
        'price_rules': [
          {
            'type': 'service_item',
            'label': 'Apartmantakarítás',
            'price': 4500,
            'unit': 'Ft/óra',
          },
        ],
        'dates': ['2026-10-12T00:00:00.000'],
        'date_hours': {
          '2026-10-12': {'from': '10:00', 'to': '12:00'},
        },
      },
    );
    await _reachService(tester, find.byKey(const ValueKey('general-hours-wd')));
    expect(find.text('08:30 – 16:30'), findsOneWidget);
    await _reachService(tester, find.byKey(const ValueKey('service-save')));
    await tester.tap(find.byKey(const ValueKey('service-save')));
    await tester.pumpAndSettle();
    final entries = jsonDecode(prefs.getString('provider_services')!) as List;
    final saved = entries.firstWhere((e) => e['id'] == 'one');
    expect(saved['dates'], ['2026-10-12T00:00:00.000']);
    expect(prefs.getString('provider_wd_from'), '08:30');
  });

  for (final height in [740.0, 772.0]) {
    testWidgets('provider dashboard controls are reachable at 360x$height', (
      tester,
    ) async {
      await _show(tester, const ProviderProfileScreen(), Size(360, height));
      expect(find.byTooltip('Értesítések'), findsOneWidget);
      expect(find.text('hibajegy'), findsOneWidget);
      for (final label in ['Üzenetek', 'Profil szerkesztése']) {
        final tile = _tile(label);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        _expectFullyVisible(tester, tile, height);
      }
      await _capture(tester, 'provider_profile_first_${height.toInt()}');
    });
    testWidgets('customer dashboard controls initially at 360x$height', (
      tester,
    ) async {
      await _show(tester, const CustomerProfileScreen(), Size(360, height));
      for (final label in ['Rendeléseim', 'Üzenetek', 'Profil szerkesztése']) {
        _expectFullyVisible(tester, _tile(label), height);
      }
      await _capture(tester, 'customer_profile_first_${height.toInt()}');
    });
    testWidgets('provider editor weekend and save initially at 360x$height', (
      tester,
    ) async {
      await _show(tester, const ProviderEditProfileScreen(), Size(360, height));
      _expectFullyVisible(tester, _tile('Szombat'), height);
      await tester.ensureVisible(_button('Módosítások mentése'));
      await tester.pumpAndSettle();
      _expectFullyVisible(tester, _button('Módosítások mentése'), height);
      await _capture(tester, 'provider_edit_first_${height.toInt()}');
    });
    testWidgets('both service editors and add initially at 360x$height', (
      tester,
    ) async {
      await _show(tester, const ProviderServicesScreen(), Size(360, height));
      final edits = find.byTooltip('Módosítás');
      expect(edits, findsNWidgets(2));
      _expectFullyVisible(tester, edits.at(0), height);
      _expectFullyVisible(tester, edits.at(1), height);
      _expectFullyVisible(tester, _button('Új szolgáltatás'), height);
      await _capture(tester, 'provider_services_first_${height.toInt()}');
    });
    testWidgets(
      'both subscriptions and complete note initially at 360x$height',
      (tester) async {
        await _show(tester, const SubscriptionScreen(), Size(360, height));
        final actions = find.byWidgetPredicate(
          (widget) => widget is FilledButton,
        );
        expect(actions, findsNWidgets(2));
        _expectFullyVisible(tester, actions.at(0), height);
        _expectFullyVisible(tester, actions.at(1), height);
        _expectFullyVisible(
          tester,
          find.textContaining('Tesztverzió:'),
          height,
        );
        await _capture(tester, 'subscriptions_first_${height.toInt()}');
      },
    );
  }

  testWidgets(
    'both filled profile editors start their common card at the same height',
    (tester) async {
      final tops = <double>[];
      for (final screen in [
        const CustomerEditProfileScreen(),
        const ProviderEditProfileScreen(),
      ]) {
        await _show(tester, screen, const Size(360, 740), canPop: true);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.text('Tímea'), findsOneWidget);
        expect(find.text('Profilkép'), findsNothing);
        tops.add(
          tester
              .getTopLeft(find.byKey(const ValueKey('profile-editor-card')))
              .dy,
        );
      }
      expect(tops[0], closeTo(tops[1], 0.1));
    },
  );

  testWidgets(
    'custom city can be selected and saved with large text and keyboard',
    (tester) async {
      await _show(
        tester,
        const CustomerEditProfileScreen(),
        const Size(320, 640),
        scale: 1.3,
        canPop: true,
      );
      final city = find.byKey(const ValueKey('profile-city'));
      await tester.ensureVisible(city);
      await tester.tap(city);
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding(top: 24);
      await tester.enterText(
        find.byKey(const ValueKey('city-search')),
        'Sárisáp',
      );
      await tester.pumpAndSettle();
      final choice = find.byKey(const ValueKey('city-use-typed'));
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
      expect(choice.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(choice).bottom,
        lessThanOrEqualTo(340),
        reason: 'The complete city choice must stay above the 300dp keyboard.',
      );
      final choicesViewport = find
          .ancestor(of: choice, matching: find.byType(Scrollable))
          .first;
      expect(
        tester.getRect(choice).bottom,
        lessThanOrEqualTo(tester.getRect(choicesViewport).bottom),
        reason: 'The result list must not clip the bottom of its city choice.',
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, 'custom_city_small_keyboard');
      await tester.tap(choice);
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding();
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
      await tester.pumpAndSettle();
      final save = _button('Módosítások mentése');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('customer_city'), 'Sárisáp');
      expect(find.text('Kezdőképernyő'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final role in ['customer', 'provider']) {
    Widget profileEditor() => role == 'customer'
        ? const CustomerEditProfileScreen()
        : const ProviderEditProfileScreen();

    testWidgets('$role editor offers no editable identity fields', (
      tester,
    ) async {
      await _show(tester, profileEditor(), const Size(360, 740), canPop: true);
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(
        fields,
        hasLength(1),
        reason: 'Only the biography is a free-text profile field.',
      );
      expect(find.byKey(const ValueKey('profile-bio')), findsOneWidget);
      expect(find.text('Tímea'), findsOneWidget);
      expect(find.text('Vezetéknév'), findsNothing);
      expect(find.text('Keresztnév'), findsNothing);
      expect(find.text('Telefonszám'), findsNothing);
    });

    testWidgets(
      '$role editor saves city and biography while preserving name and phone',
      (tester) async {
        await _show(
          tester,
          profileEditor(),
          const Size(360, 740),
          canPop: true,
        );
        await tester.enterText(
          find.byKey(const ValueKey('profile-bio')),
          'Pontos és megbízható vagyok.',
        );
        final city = find.byKey(const ValueKey('profile-city'));
        await tester.ensureVisible(city);
        await tester.tap(city);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('city-search')),
          'debrecen',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('city-option-Debrecen')));
        await tester.pumpAndSettle();
        final save = _button('Módosítások mentése');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('${role}_bio'), 'Pontos és megbízható vagyok.');
        expect(prefs.getString('${role}_city'), 'Debrecen');
        for (final prefix in ['customer', 'provider', 'registration']) {
          expect(prefs.getString('${prefix}_first_name'), 'Tímea');
          expect(prefs.getString('${prefix}_last_name'), 'Boka');
        }
        expect(prefs.getString('registration_phone'), '+36302222023');
        expect(find.text('Kezdőképernyő'), findsOneWidget);
        await _show(
          tester,
          profileEditor(),
          const Size(360, 740),
          canPop: true,
        );
        final bio = tester.widget<TextField>(
          find.byKey(const ValueKey('profile-bio')),
        );
        expect(bio.controller!.text, 'Pontos és megbízható vagyok.');
        expect(find.text('Debrecen'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$role deletion warns about three months and cancel preserves data',
      (tester) async {
        await _show(
          tester,
          const SettingsScreen(),
          const Size(360, 740),
          canPop: true,
        );
        final prefs = await SharedPreferences.getInstance();
        final before = {for (final key in prefs.getKeys()) key: prefs.get(key)};
        final delete = _button('Profil törlése');
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(find.textContaining('3 hónap'), findsOneWidget);
        await tester.tap(find.text('Mégse'));
        await tester.pumpAndSettle();
        expect({
          for (final key in prefs.getKeys()) key: prefs.get(key),
        }, before);
        expect(find.text('Beállítások'), findsWidgets);
      },
    );

    testWidgets(
      '$role confirmed deletion clears profile and blocks re-registration',
      (tester) async {
        await _show(
          tester,
          const SettingsScreen(),
          const Size(360, 740),
          canPop: true,
        );
        final delete = _button('Profil törlése');
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: _button('Profil törlése'),
          ),
        );
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('customer_first_name'), isNull);
        expect(prefs.getString('provider_first_name'), isNull);
        expect(prefs.getString('registration_phone'), isNull);
        expect(
          await AccountStore.blockedUntilFor('+36 30 222 2023'),
          isNotNull,
        );
        expect(find.text('TakiMaki'), findsOneWidget);
        expect(find.text('Kezdés'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in _sizes) {
    testWidgets(
      'service form uses the safe body and keeps all input reachable at ${size.$1}',
      (tester) async {
        await _show(
          tester,
          const ProviderAddServiceScreen(),
          Size(size.$1, size.$2),
          scale: size.$3,
          canPop: true,
        );
        final scroll = find.byKey(const ValueKey('service-form-scroll'));
        final rect = tester.getRect(scroll);
        final availableHeight = size.$2 - 24 - 56 - 48;
        expect(
          rect.height,
          greaterThanOrEqualTo(availableHeight * .90),
          reason: 'No opaque footer or bottom padding may consume the form viewport.',
        );
        final priceBuilder = find.byKey(const ValueKey('add-price-rule'));
        await _reachService(tester, priceBuilder);
        expect(priceBuilder.hitTestable(), findsOneWidget);
        final dates = find.byKey(const ValueKey('service-dates'));
        await _reachService(tester, dates);
        expect(dates.hitTestable(), findsOneWidget);
        final save = find.byKey(const ValueKey('service-save'));
        await _reachService(tester, save);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        expect(tester.getRect(save).bottom, lessThanOrEqualTo(size.$2 - 48));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('invalid service save reveals the missing selector', (
    tester,
  ) async {
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(320, 640),
      scale: 1.3,
      canPop: true,
    );
    final save = find.byKey(const ValueKey('service-save'));
    await _reachService(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Válassz szolgáltatást.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('service-selector')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing service price item is revealed', (tester) async {
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(360, 740),
      canPop: true,
    );
    await _chooseService(tester, 'Általános takarítás');
    await _capture(tester, 'service_selected_first_view');
    final save = find.byKey(const ValueKey('service-save'));
    await _reachService(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final add = find.byKey(const ValueKey('add-price-rule'));
    expect(
      find.text('Adj hozzá legalább egy ártételt vagy egyedi árajánlatot.'),
      findsOneWidget,
    );
    expect(add.hitTestable(), findsOneWidget);
    await _capture(tester, 'service_invalid_price_keyboard');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long service form reveals invalid price from the bottom after ten dates',
    (tester) async {
      final start = DateTime(2026, 10, 4);
      await _show(
        tester,
        const ProviderAddServiceScreen(),
        const Size(360, 740),
        canPop: true,
        arguments: {
          'id': 'one',
          'name': 'Apartmantakarítás',
          'price_raw': '',
          'unit': 'Ft/alkalom',
          'dates': List.generate(
            10,
            (index) => start.add(Duration(days: index)).toIso8601String(),
          ),
          'price_rules': [],
        },
      );
      final save = find.byKey(const ValueKey('service-save'));
      await _reachService(tester, save);
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('service-form-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(
        scrollable.position.pixels,
        greaterThan(800),
        reason: 'Exercise validation when the price field is far above the viewport.',
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      final add = find.byKey(const ValueKey('add-price-rule'));
      expect(add.hitTestable(), findsOneWidget);
      expect(
        find
            .text('Adj hozzá legalább egy ártételt vagy egyedi árajánlatot.')
            .hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('service price and category save from the scrolled form', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider_city', 'Debrecen');
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(360, 740),
      canPop: true,
    );
    expect(find.text('Debrecen'), findsOneWidget);
    await _chooseService(tester, 'Általános takarítás');
    await _addPriceItem(tester, 'Takarítás', 'Ft/óra', '4200');
    final save = find.byKey(const ValueKey('service-save'));
    await _reachService(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final services = jsonDecode(prefs.getString('provider_services')!) as List;
    final saved = services.singleWhere(
      (item) => item['name'] == 'Általános takarítás',
    );
    expect(saved['price_raw'], 4200);
    expect(saved['unit'], 'Ft/óra');
    expect(services, hasLength(3));
    expect(find.text('Kezdőképernyő'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'service selector uses shared pictures and readable labels with large text',
    (tester) async {
      await _show(
        tester,
        const ProviderAddServiceScreen(),
        const Size(320, 640),
        scale: 1.3,
        canPop: true,
      );
      await tester.tap(find.byKey(const ValueKey('service-selector')));
      await tester.pumpAndSettle();
      for (final label in [
        'Apartmantakarítás',
        'Felújítás utáni takarítás',
        'Bútorösszeszerelés',
      ]) {
        final option = find.byKey(ValueKey('service-option-$label'));
        await tester.scrollUntilVisible(
          option,
          100,
          scrollable: find.byType(Scrollable).last,
        );
        expect(option.hitTestable(), findsOneWidget);
        final picture = tester.widget<Image>(
          find.descendant(of: option, matching: find.byType(Image)),
        );
        expect((picture.image as AssetImage).assetName, serviceImage(label));
        expect(tester.takeException(), isNull);
      }
      await _capture(tester, 'service_selector_small_large_text');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('apartment price items remain editable at 320 with large text', (
    tester,
  ) async {
    await _show(
      tester,
      const ProviderAddServiceScreen(),
      const Size(320, 640),
      scale: 1.3,
      canPop: true,
    );
    await _chooseService(tester, 'Apartmantakarítás');
    final add = find.byKey(const ValueKey('add-price-rule'));
    await _reachService(tester, add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('price-item-Apartmantakarítás')),
    );
    await tester.pumpAndSettle();
    final unit = find.byKey(const ValueKey('price-unit-Ft/m²'));
    await tester.ensureVisible(unit);
    await tester.pumpAndSettle();
    await tester.tap(unit);
    await tester.pumpAndSettle();
    final amount = find.byKey(const ValueKey('price-rule-amount'));
    await tester.ensureVisible(amount);
    await tester.pumpAndSettle();
    await tester.enterText(amount, '15000');
    await tester.tap(_button('Hozzáadás'));
    await tester.pumpAndSettle();
    expect(find.text('15 000 Ft/m²'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleted phone cannot proceed to verification', (tester) async {
    await AccountStore.deleteAccount();
    await _show(
      tester,
      const PhoneNumberScreen(),
      const Size(360, 740),
      canPop: true,
    );
    await tester.enterText(find.byType(TextField), '+36 30 222 2023');
    await tester.pumpAndSettle();
    final button = _button('Kód kérése');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.textContaining('nem lehet újra regisztrálni'), findsOneWidget);
    expect(find.byType(OtpVerifyScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text provider save remains reachable by scrolling', (
    tester,
  ) async {
    await _show(
      tester,
      const ProviderEditProfileScreen(),
      const Size(320, 640),
      scale: 1.3,
    );
    final save = _button('Módosítások mentése');
    await tester.scrollUntilVisible(
      save,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'large text lower dashboard tile remains reachable by scrolling',
    (tester) async {
      await _show(
        tester,
        const ProviderProfileScreen(),
        const Size(320, 640),
        scale: 1.3,
      );
      final tile = _tile('Profil szerkesztése');
      await tester.scrollUntilVisible(
        tile,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tile.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('phone action is reachable above the keyboard', (tester) async {
    await _show(
      tester,
      const PhoneNumberScreen(),
      const Size(360, 740),
      keyboard: 300,
    );
    final action = _button('Kód kérése');
    await tester.scrollUntilVisible(
      action,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(action).bottom, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });
  testWidgets('chat composer stays above keyboard and input is usable', (
    tester,
  ) async {
    await _show(
      tester,
      const ChatThreadScreen(threadId: 'layout-chat'),
      const Size(360, 740),
      keyboard: 300,
    );
    await tester.enterText(find.byType(TextField), 'Rendben, köszönöm.');
    await tester.pumpAndSettle();
    final send = find.byTooltip('Küldés');
    expect(send.hitTestable(), findsOneWidget);
    expect(tester.getRect(send).bottom, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _reachService(WidgetTester tester, Finder target) async {
  final scrollable = find
      .descendant(
        of: find.byKey(const ValueKey('service-form-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 100, scrollable: scrollable);
  await tester.pumpAndSettle();
}

Future<void> _chooseService(WidgetTester tester, String name) async {
  final selector = find.byKey(const ValueKey('service-selector'));
  await tester.ensureVisible(selector);
  await tester.tap(selector);
  await tester.pumpAndSettle();
  final option = find.byKey(ValueKey('service-option-$name'));
  await tester.scrollUntilVisible(
    option,
    100,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _addPriceItem(
  WidgetTester tester,
  String item,
  String unit,
  String amount,
) async {
  final add = find.byKey(const ValueKey('add-price-rule'));
  await _reachService(tester, add);
  await tester.tap(add);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('price-item-$item')));
  await tester.pumpAndSettle();
  final unitChoice = find.byKey(ValueKey('price-unit-$unit'));
  await tester.ensureVisible(unitChoice);
  await tester.pumpAndSettle();
  await tester.tap(unitChoice);
  await tester.pumpAndSettle();
  final amountField = find.byKey(const ValueKey('price-rule-amount'));
  await tester.ensureVisible(amountField);
  await tester.pumpAndSettle();
  await tester.enterText(amountField, amount);
  await tester.tap(find.byKey(const ValueKey('price-rule-add')));
  await tester.pumpAndSettle();
}

Finder _button(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
);
Finder _tile(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(InkWell)).first;

void _expectFullyVisible(WidgetTester tester, Finder finder, double height) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(
    rect.right,
    lessThanOrEqualTo(
      tester.view.physicalSize.width / tester.view.devicePixelRatio + .01,
    ),
  );
  expect(rect.top, greaterThanOrEqualTo(24));
  expect(
    rect.bottom,
    lessThanOrEqualTo(height - 48 - 12),
    reason: 'Whole control must stay at least 12dp above Android navigation.',
  );
  expect(finder.hitTestable(), findsOneWidget);
}

Future<void> _show(
  WidgetTester tester,
  Widget screen,
  Size size, {
  double scale = 1,
  double keyboard = 0,
  bool canPop = false,
  Object? arguments,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
  tester.view.padding = FakeViewPadding(
    top: 24,
    bottom: keyboard == 0 ? 48 : 0,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: MaterialApp(
        key: UniqueKey(),
        debugShowCheckedModeBanner: false,
        theme: takimakiTheme().copyWith(
          platform: TargetPlatform.android,
          textTheme: takimakiTheme().textTheme.apply(fontFamily: 'Roboto'),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('hu')],
        locale: const Locale('hu'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: BrandedBackground(child: child!),
        ),
        home: canPop ? null : screen,
        routes: canPop
            ? {'/': (_) => const Scaffold(body: Text('Kezdőképernyő'))}
            : const {},
        onGenerateInitialRoutes: canPop
            ? (_) => [
                MaterialPageRoute<dynamic>(
                  settings: const RouteSettings(name: '/'),
                  builder: (_) => const Scaffold(body: Text('Kezdőképernyő')),
                ),
                MaterialPageRoute<dynamic>(
                  settings: RouteSettings(
                    name: '/test-screen',
                    arguments: arguments,
                  ),
                  builder: (_) => screen,
                ),
              ]
            : null,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final context = tester.element(find.byType(MaterialApp));
    await Future.wait(
      serviceChoices.map(
        (entry) => precacheImage(AssetImage(entry['image']!), context),
      ),
    );
  });
  _useLoadedTestFonts(tester);
  await tester.pumpAndSettle();
}

InlineSpan _fontSpan(InlineSpan span) {
  if (span is! TextSpan) return span;
  final style = span.style;
  final replace = style?.fontFamily == null || style?.fontFamily == 'Ahem';
  return TextSpan(
    text: span.text,
    style: replace
        ? (style ?? const TextStyle()).copyWith(fontFamily: 'Roboto')
        : style,
    children: span.children?.map(_fontSpan).toList(),
    recognizer: span.recognizer,
    semanticsLabel: span.semanticsLabel,
  );
}

void _useLoadedTestFonts(WidgetTester tester) {
  void visit(Element element) {
    final render = element.renderObject;
    if (render is RenderParagraph) render.text = _fontSpan(render.text);
    if (render is RenderEditable && render.text != null)
      render.text = _fontSpan(render.text!);
    element.visitChildren(visit);
  }

  tester.element(find.byType(MaterialApp)).visitChildren(visit);
}

Future<void> _capture(WidgetTester tester, String name) async {
  final directory = Platform.environment['TAKIMAKI_CAPTURE'];
  if (directory == null) return;
  _useLoadedTestFonts(tester);
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(directory).create(recursive: true);
    await File('$directory/$name.png').writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
