import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sanctions_store.dart';
import 'workflow_store.dart';

class LocalMarketplaceStore {
  static const requestsKey = 'provider_requests';
  static const offersKey = 'customer_offers';
  static const customerOrdersKey = 'customer_orders';
  static const providerOrdersKey = 'provider_orders';
  static const providerFirstAcceptedKey = 'provider_first_order_accepted';
  static const providerSubscriptionKey = 'provider_subscription_active';
  static const customerTrialStartedKey = 'customer_trial_started_at';
  static const customerSubscriptionKey = 'customer_subscription_active';

  static DateTime? responseDeadline(Map<String, dynamic> item) {
    final created = DateTime.tryParse(item['created_at']?.toString() ?? '');
    final date = item['date']?.toString() ?? '';
    final time = item['time']?.toString() ?? '';
    final workAt = DateTime.tryParse('${date}T$time:00');
    if (created == null && workAt == null) return null;
    final normalDeadline = (created ?? DateTime.now()).add(
      const Duration(hours: 24),
    );
    final workDeadline = workAt?.subtract(const Duration(hours: 1));
    if (workDeadline == null) return normalDeadline;
    return workDeadline.isBefore(normalDeadline)
        ? workDeadline
        : normalDeadline;
  }

  static bool isResponseExpired(Map<String, dynamic> item) {
    final deadline = responseDeadline(item);
    return deadline != null && !DateTime.now().isBefore(deadline);
  }

  static Future<List<Map<String, dynamic>>> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (json.decode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(items));
  }

  static Future<String> createRequest({
    required String service,
    required String address,
    required DateTime dateTime,
    required String note,
    required bool laundryAndIroning,
    List<String> serviceOptions = const [],
    int? areaSqm,
    int durationMinutes = 60,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString('customer_last_name') ?? '';
    final firstName = prefs.getString('customer_first_name') ?? '';
    final customerName = [
      lastName,
      firstName,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final id = 'R${DateTime.now().millisecondsSinceEpoch}';
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    if (durationMinutes <= 0) throw StateError('Érvényes időtartam szükséges.');
    final request = <String, dynamic>{
      'id': id,
      'request_id': id,
      'service': service,
      'customer': customerName.isEmpty ? 'Megrendelő' : customerName,
      'customer_first_name': firstName,
      'customer_id': prefs.getString('registration_phone'),
      'duration_minutes': durationMinutes,
      if (areaSqm != null) 'area_sqm': areaSqm,
      'customer_photo_b64':
          prefs.getString('profile_photo_b64') ??
          prefs.getString('customer_profile_photo_b64'),
      'customer_photo_path':
          prefs.getString('customer_photo_path') ??
          prefs.getString('registration_photo_path'),
      'customer_bio': prefs.getString('customer_bio') ?? '',
      'customer_success_count': prefs.getInt('customer_success_count') ?? 0,
      'customer_rating': prefs.getDouble('customer_rating'),
      'address': address,
      'date': date,
      'time': time,
      'note': note,
      'laundry_and_ironing': laundryAndIroning,
      'service_options': serviceOptions,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    final requests = await _read(requestsKey);
    requests.insert(0, request);
    await _write(requestsKey, requests);

    final orders = await _read(customerOrdersKey);
    orders.insert(0, {...request, 'title': service, 'status': 'Függőben'});
    await _write(customerOrdersKey, orders);
    return id;
  }

  static Future<List<Map<String, dynamic>>> offersFor(String requestId) async {
    final offers = await _read(offersKey);
    return offers.where((item) => item['request_id'] == requestId).toList();
  }

  static Future<Map<String, dynamic>?> ownOfferFor(
    Map<String, dynamic> request,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final requestId = (request['request_id'] ?? request['id']).toString();
    final providerId = prefs.getString('registration_phone');
    final name = [
      prefs.getString('provider_last_name') ??
          prefs.getString('customer_last_name') ??
          '',
      prefs.getString('provider_first_name') ??
          prefs.getString('customer_first_name') ??
          '',
    ].where((part) => part.trim().isNotEmpty).join(' ');
    return (await _read(offersKey))
        .where(
          (offer) =>
              offer['request_id'].toString() == requestId &&
              offer['status'] == 'pending' &&
              ((providerId != null && offer['provider_id'] == providerId) ||
                  (name.isNotEmpty && offer['provider_name'] == name)),
        )
        .firstOrNull;
  }

  static Future<void> ensureTestOffers(String requestId, String service) async {
    final offers = await _read(offersKey);
    if (offers.any((item) => item['request_id'] == requestId)) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    offers.addAll([
      {
        'id': 'TEST${now}A',
        'request_id': requestId,
        'service': service,
        'provider_name': 'Nagy Petra',
        'provider_success_count': 24,
        'provider_rating': 4.9,
        'provider_rating_count': 18,
        'price': 14500,
        'note': 'Az időpont megfelelő, az eszközöket viszem.',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'TEST${now}B',
        'request_id': requestId,
        'service': service,
        'provider_name': 'Tiszta Otthon',
        'provider_success_count': 41,
        'provider_rating': 4.8,
        'provider_rating_count': 32,
        'price': 16900,
        'note': 'Megbízható, számlaképes szolgáltató.',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    await _write(offersKey, offers);
  }

  static String _serviceKey(Object? value) => (value?.toString() ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  static Future<Set<String>> _providerServiceNames() async {
    final services = await _read('provider_services');
    return services
        .map((item) => _serviceKey(item['name']))
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  static Future<List<Map<String, dynamic>>> _providerServices() =>
      _read('provider_services');

  static bool _providerMatchesRequestOptions(
    Map<String, dynamic> providerService,
    Map<String, dynamic> request,
  ) {
    final requested =
        (request['service_options'] as List?)
            ?.map((value) => value.toString())
            .toSet() ??
        const <String>{};
    if (requested.isEmpty) return true;
    final offered =
        (providerService['service_options'] as List?)
            ?.map((value) => value.toString())
            .toSet() ??
        const <String>{};
    final prices = (providerService['price_rules'] as List?) ?? const [];
    final available = {
      ...offered,
      ...prices.whereType<Map>().map((rule) => rule['label'].toString()),
    };
    return available.containsAll(requested);
  }

  static DateTime _easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = (h + l - 7 * m + 114) % 31 + 1;
    return DateTime(year, month, day);
  }

  static bool _isHungarianPublicHoliday(DateTime date) {
    final fixed = <String>{
      '1-1', '3-15', '5-1', '8-20', '10-23', '11-1', '12-25', '12-26',
    };
    if (fixed.contains('${date.month}-${date.day}')) return true;
    final easter = _easterSunday(date.year);
    final day = DateTime(date.year, date.month, date.day);
    return day.millisecondsSinceEpoch ==
            easter.subtract(const Duration(days: 2)).millisecondsSinceEpoch ||
        day.millisecondsSinceEpoch ==
            easter.add(const Duration(days: 1)).millisecondsSinceEpoch ||
        day.millisecondsSinceEpoch ==
            easter.add(const Duration(days: 50)).millisecondsSinceEpoch;
  }

  static bool _hasCustomDate(
    Map<String, dynamic> providerService,
    DateTime date,
  ) {
    final key = DateTime(date.year, date.month, date.day);
    return (providerService['dates'] as List? ?? const [])
        .map((value) => DateTime.tryParse(value.toString()))
        .whereType<DateTime>()
        .any((value) => DateTime(value.year, value.month, value.day) == key);
  }

  static bool _isOpenRequest(Map<String, dynamic> request) =>
      const ['pending', 'offered'].contains(request['status']) &&
      !isResponseExpired(request);

  static Future<List<Map<String, dynamic>>> providerRequests() async {
    final services = await _providerServices();
    final requests = await _read(requestsKey);
    final prefs = await SharedPreferences.getInstance();
    final ownId = prefs.getString('registration_phone');
    final worksOnHolidays = prefs.getBool('provider_holidays') ?? false;
    final ownOrders = await _read(customerOrdersKey);
    return requests.where((request) {
      final service = services
          .where(
            (item) =>
                _serviceKey(item['name']) == _serviceKey(request['service']),
          )
          .firstOrNull;
      return !isOwnRequest(request, ownId, ownOrders) &&
          service != null &&
          (() {
            final date = DateTime.tryParse(request['date']?.toString() ?? '');
            if (date == null || !_isHungarianPublicHoliday(date)) return true;
            return worksOnHolidays || _hasCustomDate(service, date);
          })() &&
          _providerMatchesRequestOptions(service, request) &&
          _isOpenRequest(request);
    }).toList();
  }

  static bool isOwnRequest(
    Map<String, dynamic> request,
    String? ownId,
    List<Map<String, dynamic>> ownOrders,
  ) {
    if (ownId == null || ownId.isEmpty) return false;
    final customerId = request['customer_id']?.toString();
    if (ownId != null && ownId.isNotEmpty && customerId == ownId) return true;
    if (customerId != null && customerId.isNotEmpty) return false;
    final id = (request['request_id'] ?? request['id'])?.toString();
    return id != null &&
        ownOrders.any(
          (order) => (order['request_id'] ?? order['id'])?.toString() == id,
        );
  }

  static Future<String?> offerBlockReason(Map<String, dynamic> request) async {
    final id = (request['request_id'] ?? request['id'])?.toString();
    final current = (await _read(requestsKey))
        .where((item) => (item['request_id'] ?? item['id'])?.toString() == id)
        .firstOrNull;
    if (current == null || !_isOpenRequest(current)) {
      return 'Ez az ajánlatkérés már lezárult vagy lejárt.';
    }
    final ownershipPrefs = await SharedPreferences.getInstance();
    if (isOwnRequest(
      current,
      ownershipPrefs.getString('registration_phone'),
      await _read(customerOrdersKey),
    )) {
      return 'A saját megrendelésedre nem küldhetsz ajánlatot.';
    }
    final providerService = (await _providerServices())
        .where(
          (item) =>
              _serviceKey(item['name']) == _serviceKey(current['service']),
        )
        .firstOrNull;
    if (providerService == null) {
      return 'Erre a szolgáltatásra nincs aktív szolgáltatásod.';
    }
    if (!_providerMatchesRequestOptions(providerService, current)) {
      return 'A megrendelő olyan kiegészítő szolgáltatást kér, amelyet nem jelöltél vállalhatónak.';
    }
    final prefs = await SharedPreferences.getInstance();
    final name = [
      prefs.getString('provider_last_name') ??
          prefs.getString('customer_last_name') ??
          '',
      prefs.getString('provider_first_name') ??
          prefs.getString('customer_first_name') ??
          '',
    ].where((v) => v.trim().isNotEmpty).join(' ');
    try {
      await WorkflowStore.checkConflict({
        ...current,
        'provider_id': prefs.getString('registration_phone'),
        'provider_name': name,
      });
    } on StateError catch (error) {
      return error.message.toString();
    }
    if (await SanctionsStore.isProviderSuspended()) {
      return 'A szolgáltatói fiókod jelenleg fel van függesztve.';
    }
    if (!await canProviderSendOffer()) {
      return 'Az első elfogadott munka után aktív szolgáltatói előfizetés szükséges.';
    }
    return null;
  }

  static Future<void> sendOffer({
    required Map<String, dynamic> request,
    required int price,
    required String note,
    String? providerName,
  }) async {
    if (price <= 0) throw StateError('Adj meg érvényes árat.');
    final blocked = await offerBlockReason(request);
    if (blocked != null) throw StateError(blocked);
    final prefs = await SharedPreferences.getInstance();
    final lastName =
        prefs.getString('provider_last_name') ??
        prefs.getString('customer_last_name') ??
        '';
    final firstName =
        prefs.getString('provider_first_name') ??
        prefs.getString('customer_first_name') ??
        '';
    final savedName = [
      lastName,
      firstName,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final resolvedProviderName = providerName?.trim().isNotEmpty == true
        ? providerName!.trim()
        : (savedName.isEmpty ? 'Szolgáltató' : savedName);
    final successCount = prefs.getInt('provider_success_count') ?? 0;
    final requestId = (request['request_id'] ?? request['id']).toString();
    final offers = await _read(offersKey);
    offers.removeWhere(
      (item) =>
          item['request_id'] == requestId &&
          item['provider_name'] == resolvedProviderName &&
          item['status'] == 'pending',
    );
    offers.insert(0, {
      'id': 'O${DateTime.now().millisecondsSinceEpoch}',
      'request_id': requestId,
      'service': request['service'],
      'provider_name': resolvedProviderName,
      'provider_first_name': providerName == null ? firstName : null,
      'provider_id': prefs.getString('registration_phone'),
      'duration_minutes': request['duration_minutes'] ?? 60,
      if (request['area_sqm'] != null) 'area_sqm': request['area_sqm'],
      'service_options': request['service_options'] ?? const <String>[],
      'laundry_and_ironing': request['laundry_and_ironing'] == true,
      'provider_photo_b64':
          prefs.getString('profile_photo_b64') ??
          prefs.getString('provider_profile_photo_b64'),
      'provider_photo_path':
          prefs.getString('provider_photo_path') ??
          prefs.getString('registration_photo_path'),
      'provider_bio': prefs.getString('provider_bio') ?? '',
      'provider_success_count': successCount,
      'provider_rating': successCount >= 5
          ? prefs.getDouble('provider_rating')
          : null,
      'provider_rating_count': successCount >= 5
          ? prefs.getInt('provider_rating_count') ?? 0
          : 0,
      'address': request['address'],
      'date': request['date'],
      'time': request['time'],
      'price': price,
      'note': note,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    await _write(offersKey, offers);
    await updateRequestStatus(requestId, 'offered');
    await WorkflowStore.enqueue(
      requestId,
      'customer',
      'Új ajánlat érkezett',
      '$resolvedProviderName • $price Ft',
    );
  }

  static Future<void> rejectOffer(String offerId) async {
    final offers = await _read(offersKey);
    final index = offers.indexWhere((item) => item['id'].toString() == offerId);
    if (index < 0) return;
    offers[index]['status'] = 'rejected';
    await _write(offersKey, offers);
  }

  static Future<void> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    final requests = await _read(requestsKey);
    final index = requests.indexWhere(
      (item) => (item['request_id'] ?? item['id']).toString() == requestId,
    );
    if (index >= 0) {
      requests[index]['status'] = status;
      await _write(requestsKey, requests);
    }
  }

  static Future<void> acceptOffer(Map<String, dynamic> offer) async {
    final requestId = offer['request_id'].toString();
    final offerId = offer['id'].toString();
    final offers = await _read(offersKey);
    final savedOffer = offers
        .where(
          (item) =>
              item['id'].toString() == offerId &&
              item['request_id'].toString() == requestId,
        )
        .firstOrNull;
    if (savedOffer == null || savedOffer['status'] != 'pending')
      throw StateError('Ez az ajánlat már nem fogadható el.');
    offer = savedOffer;
    final requests = await _read(requestsKey);
    final request = requests
        .where(
          (item) => (item['request_id'] ?? item['id']).toString() == requestId,
        )
        .firstOrNull;
    if (request == null || !_isOpenRequest(request))
      throw StateError('A megrendelés már lezárult vagy lejárt.');
    final prefsForOwner = await SharedPreferences.getInstance();
    final customerId =
        request['customer_id']?.toString() ??
        prefsForOwner.getString('registration_phone');
    final providerId = offer['provider_id']?.toString();
    if (providerId != null && providerId.isNotEmpty && providerId == customerId)
      throw StateError('A saját megrendelésedet nem vállalhatod el.');
    await WorkflowStore.checkConflict({...request, ...offer});
    for (final item in offers) {
      if (item['request_id'] == requestId)
        item['status'] = item['id'].toString() == offerId
            ? 'accepted'
            : 'inactive';
    }
    await _write(offersKey, offers);

    final acceptedOrder = <String, dynamic>{
      if (request != null) ...request,
      ...offer,
      'provider': offer['provider_name'],
      'status': 'Elfogadva',
    };
    final customerOrders = await _read(customerOrdersKey);
    final customerIndex = customerOrders.indexWhere(
      (item) => (item['request_id'] ?? item['id']).toString() == requestId,
    );
    if (customerIndex >= 0) {
      customerOrders[customerIndex] = {
        ...customerOrders[customerIndex],
        ...acceptedOrder,
      };
    } else {
      customerOrders.insert(0, acceptedOrder);
    }
    await _write(customerOrdersKey, customerOrders);

    final providerOrders = await _read(providerOrdersKey);
    providerOrders.removeWhere(
      (item) => item['request_id'].toString() == requestId,
    );
    providerOrders.insert(0, acceptedOrder);
    await _write(providerOrdersKey, providerOrders);
    await updateRequestStatus(requestId, 'accepted');
    await WorkflowStore.reconcileReminders(acceptedOrder);
    await WorkflowStore.enqueue(
      requestId,
      'provider',
      'Új elfogadott munka',
      '${acceptedOrder['service']} • ${acceptedOrder['date']} ${acceptedOrder['time']}',
    );
    final prefs = await SharedPreferences.getInstance();
    if (!offerId.startsWith('TEST')) {
      await prefs.setBool(providerFirstAcceptedKey, true);
    }
  }

  static Future<bool> canProviderSendOffer() async {
    if (await SanctionsStore.isProviderSuspended()) return false;
    final prefs = await SharedPreferences.getInstance();
    var usedFreeOrder = prefs.getBool(providerFirstAcceptedKey) ?? false;
    if (usedFreeOrder) {
      final history = await _read(providerOrdersKey);
      if (history.isNotEmpty &&
          history.every((order) => order['id'].toString().startsWith('TEST'))) {
        // Legacy generated offers must not consume a real provider's free job.
        usedFreeOrder = false;
        await prefs.setBool(providerFirstAcceptedKey, false);
      }
    }
    final paid = prefs.getBool(providerSubscriptionKey) ?? false;
    return !usedFreeOrder || paid;
  }

  static Future<bool> canCustomerCreateOrder() async {
    if (await SanctionsStore.isCustomerSuspended()) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(customerSubscriptionKey) ?? false) return true;
    final rawStart = prefs.getString(customerTrialStartedKey);
    if (rawStart == null) return true;
    final start = DateTime.tryParse(rawStart);
    if (start == null) return true;
    return DateTime.now().isBefore(start.add(const Duration(days: 90)));
  }

  static Future<List<Map<String, dynamic>>> customerOrders() =>
      _read(customerOrdersKey);

  static Future<List<Map<String, dynamic>>> providerOrders() =>
      _read(providerOrdersKey);

  static Future<void> updateOrderStatus(String requestId, String status) async {
    for (final key in [customerOrdersKey, providerOrdersKey]) {
      final orders = await _read(key);
      final index = orders.indexWhere(
        (item) => (item['request_id'] ?? item['id']).toString() == requestId,
      );
      if (index >= 0) {
        orders[index]['status'] = status;
        await _write(key, orders);
      }
    }
    final updated = (await customerOrders())
        .where((w) => (w['request_id'] ?? w['id']).toString() == requestId)
        .firstOrNull;
    if (updated != null) await WorkflowStore.reconcileReminders(updated);
    if (status == 'Lemondva') await updateRequestStatus(requestId, 'cancelled');
    if (status == 'Teljesítve') {
      final prefs = await SharedPreferences.getInstance();
      final providerOrders = await _read(providerOrdersKey);
      final providerCompleted = providerOrders
          .where((item) => item['status'] == 'Teljesítve')
          .length;
      final customerOrders = await _read(customerOrdersKey);
      final customerCompleted = customerOrders
          .where((item) => item['status'] == 'Teljesítve')
          .length;
      await prefs.setInt('provider_success_count', providerCompleted);
      await prefs.setInt('customer_success_count', customerCompleted);
    }
  }

  static Future<bool> recordOrderAction({
    required String requestId,
    required String key,
    required dynamic value,
  }) async {
    var found = false;
    for (final storeKey in [customerOrdersKey, providerOrdersKey]) {
      final orders = await _read(storeKey);
      final index = orders.indexWhere(
        (item) => (item['request_id'] ?? item['id']).toString() == requestId,
      );
      if (index >= 0) {
        found = true;
        if (orders[index][key] != null) return false;
      }
    }
    if (!found) return false;
    for (final storeKey in [customerOrdersKey, providerOrdersKey]) {
      final orders = await _read(storeKey);
      final index = orders.indexWhere(
        (item) => (item['request_id'] ?? item['id']).toString() == requestId,
      );
      if (index >= 0) {
        orders[index][key] = value;
        await _write(storeKey, orders);
      }
    }
    return true;
  }

  static Future<void> rateOrder({
    required String requestId,
    required int rating,
    required String review,
  }) async {
    final safeRating = rating.clamp(1, 5);
    for (final key in [customerOrdersKey, providerOrdersKey]) {
      final orders = await _read(key);
      final index = orders.indexWhere(
        (item) => (item['request_id'] ?? item['id']).toString() == requestId,
      );
      if (index >= 0) {
        orders[index]['rating'] = safeRating;
        orders[index]['review'] = review;
        await _write(key, orders);
      }
    }

    final providerOrders = await _read(providerOrdersKey);
    final ratings = providerOrders
        .map((item) => item['rating'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
    if (ratings.isNotEmpty) {
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('provider_rating', average);
      await prefs.setInt('provider_rating_count', ratings.length);
    }
  }
}
