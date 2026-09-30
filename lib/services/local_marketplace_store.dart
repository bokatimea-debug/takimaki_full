import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sanctions_store.dart';

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
    String district = '',
    required String address,
    required DateTime dateTime,
    required String note,
    required bool laundryAndIroning,
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
    final request = <String, dynamic>{
      'id': id,
      'request_id': id,
      'service': service,
      'customer': customerName.isEmpty ? 'Megrendelő' : customerName,
      'customer_photo_path':
          prefs.getString('customer_photo_path') ??
          prefs.getString('registration_photo_path'),
      'customer_bio': prefs.getString('customer_bio') ?? '',
      'customer_success_count': prefs.getInt('customer_success_count') ?? 0,
      'customer_rating': prefs.getDouble('customer_rating'),
      'district': district,
      'address': address,
      'date': date,
      'time': time,
      'note': note,
      'laundry_and_ironing': laundryAndIroning,
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

  static Future<void> sendOffer({
    required Map<String, dynamic> request,
    required int price,
    required String note,
    String? providerName,
  }) async {
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
      'district': request['district'],
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
    for (final item in offers) {
      if (item['request_id'] == requestId) {
        item['status'] = item['id'].toString() == offerId
            ? 'accepted'
            : 'inactive';
      }
    }
    await _write(offersKey, offers);

    final acceptedOrder = <String, dynamic>{
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(providerFirstAcceptedKey, true);
  }

  static Future<bool> canProviderSendOffer() async {
    if (await SanctionsStore.isProviderSuspended()) return false;
    final prefs = await SharedPreferences.getInstance();
    final usedFreeOrder = prefs.getBool(providerFirstAcceptedKey) ?? false;
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
