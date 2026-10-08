import 'package:flutter_test/flutter_test.dart';
import 'package:takimaki_full/data/service_pricing_catalog.dart';
import 'package:takimaki_full/widgets/service_choice_grid.dart';

void main() {
  test('apartment capability and price tiles match the approved compact set',
      () {
    expect(
      serviceOptionLabels['Apartmantakarítás'],
      orderedEquals(['Mosodai szolgáltatás', 'Helyszíni mosás']),
    );
    expect(
      servicePriceItems['Apartmantakarítás'],
      orderedEquals(['Apartmantakarítás', 'Mosás', 'Vasalás']),
    );
  });

  test('new services are available to customer and provider selectors', () {
    final names = serviceChoices.map((item) => item['name']).toSet();
    expect(names, containsAll(['Kárpittisztítás', 'Lefolyótisztítás']));
    expect(servicePriceItems['Kárpittisztítás'], isNotEmpty);
    expect(servicePriceItems['Lefolyótisztítás'], isNotEmpty);
  });

  test('trade-specific pricing choices and permit warnings are configured', () {
    expect(
        servicePriceItems['Gázszerelés'],
        containsAll([
          'Kiszállás',
          'Kazántisztítás',
          'Konvektortisztítás',
          'Szerelés',
        ]));
    expect(
      pricingUnitsFor('Bútorösszeszerelés', 'Bútorösszeszerelés'),
      containsAll(['Ft/óra', 'Ft/alkalom', '%', 'Egyedi árajánlat']),
    );
    expect(
      pricingUnitsFor('Vízszerelés', 'Kiszállás'),
      orderedEquals(['Ft/alkalom', 'Egyedi árajánlat']),
    );
    expect(
      pricingUnitsFor('Gázszerelés', 'Kazántisztítás'),
      orderedEquals(['Ft/alkalom', 'Egyedi árajánlat']),
    );
    expect(serviceNeedsPermitWarning('Gázszerelés'), isTrue);
    expect(serviceNeedsPermitWarning('Villanyszerelés'), isTrue);
  });
}
