import '../lib/data/service_pricing_catalog.dart';
class Ownership {
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

}
void main() {
assert(serviceOptionLabels['Apartmantakarítás']!.join('|') == 'Mosodai szolgáltatás|Helyszíni mosás');
assert(servicePriceItems['Apartmantakarítás']!.join('|') == 'Apartmantakarítás|Mosás|Vasalás');
assert(Ownership.isOwnRequest({'id':'a','customer_id':'me'}, 'me', []));
assert(!Ownership.isOwnRequest({'id':'a','customer_id':'other'}, 'me', []));
assert(!Ownership.isOwnRequest({'id':'a'}, 'me', []));
assert(Ownership.isOwnRequest({'id':'a'}, 'me', [{'request_id':'a'}]));
assert(!Ownership.isOwnRequest({'id':'a','customer_id':'other'}, 'me', [{'request_id':'a'}]));
assert(!Ownership.isOwnRequest({'id':'a'}, null, []));
print('8 catalog and identity checks passed');
}
