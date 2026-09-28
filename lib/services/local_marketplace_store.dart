import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalMarketplaceStore {
  static const requestsKey = 'provider_requests';
  static const offersKey = 'customer_offers';
  static const customerOrdersKey = 'customer_orders';
  static const providerOrdersKey = 'provider_orders';
  static const providerFirstAcceptedKey = 'provider_first_order_accepted';
  static const providerSubscriptionKey = 'provider_subscription_active';
  static const customerTrialStartedKey = 'customer_trial_started_at';
  static const customerSubscriptionKey = 'customer_subscription_active';

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

  static Future<void> _write(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(items));
  }

  static Future<String> createRequest({
    required String service,
    required String district,
    required String address,
    required DateTime dateTime,
    required String note,
    required bool laundryAndIroning,
  }) async {
    final id = 'R${DateTime.now().millisecondsSinceEpoch}';
    final date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final request = <String, dynamic>{
      'id': id,
      'request_id': id,
      'service': service,
      'customer': 'Megrendelő',
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
    String providerName = 'Szolgáltató',
  }) async {
    final requestId = (request['request_id'] ?? request['id']).toString();
    final offers = await _read(offersKey);
    offers.removeWhere((item) =>
        item['request_id'] == requestId &&
        item['provider_name'] == providerName &&
        item['status'] == 'pending');
    offers.insert(0, {
      'id': 'O${DateTime.now().millisecondsSinceEpoch}',
      'request_id': requestId,
      'service': request['service'],
      'provider_name': providerName,
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

  static Future<void> updateRequestStatus(String requestId, String status) async {
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
        item['status'] = item['id'].toString() == offerId ? 'accepted' : 'inactive';
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
    providerOrders.removeWhere((item) => item['request_id'].toString() == requestId);
    providerOrders.insert(0, acceptedOrder);
    await _write(providerOrdersKey, providerOrders);
    await updateRequestStatus(requestId, 'accepted');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(providerFirstAcceptedKey, true);
  }

  static Future<bool> canProviderSendOffer() async {
    final prefs = await SharedPreferences.getInstance();
    final usedFreeOrder = prefs.getBool(providerFirstAcceptedKey) ?? false;
    final paid = prefs.getBool(providerSubscriptionKey) ?? false;
    return !usedFreeOrder || paid;
  }

  static Future<bool> canCustomerCreateOrder() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(customerSubscriptionKey) ?? false) return true;
    final rawStart = prefs.getString(customerTrialStartedKey);
    if (rawStart == null) return true;
    final start = DateTime.tryParse(rawStart);
    if (start == null) return true;
    return DateTime.now().isBefore(start.add(const Duration(days: 90)));
  }

  static Future<List<Map<String, dynamic>>> customerOrders() => _read(customerOrdersKey);
}
