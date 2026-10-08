const serviceOptionLabels = <String, List<String>>{
  'Apartmantakarítás': ['Mosodai szolgáltatás', 'Helyszíni mosás'],
  'Mosodai szolgáltatás': [
    'Mosás',
    'Vasalás',
    'Bértextília',
    'Háztól házig szolgáltatás',
  ],
};

const servicePriceItems = <String, List<String>>{
  'Apartmantakarítás': ['Apartmantakarítás', 'Mosás', 'Vasalás'],
  'Mosodai szolgáltatás': ['Mosás', 'Vasalás', 'Bértextília', 'Kiszállás'],
  'Általános takarítás': ['Takarítás', 'Kiszállás'],
  'Nagytakarítás': ['Nagytakarítás', 'Kiszállás'],
  'Felújítás utáni takarítás': ['Felújítás utáni takarítás', 'Kiszállás'],
  'Vízszerelés': ['Kiszállás', 'Szerelés'],
  'Gázszerelés': [
    'Kiszállás',
    'Kazántisztítás',
    'Konvektortisztítás',
    'Szerelés',
  ],
  'Villanyszerelés': ['Kiszállás', 'Szerelés'],
  'Karbantartás': ['Kiszállás', 'Karbantartás'],
  'Klímatisztítás és -javítás': ['Kiszállás', 'Klímatisztítás', 'Klímajavítás'],
  'Bútorösszeszerelés': ['Kiszállás', 'Bútorösszeszerelés'],
  'Kárpittisztítás': [
    'Kiszállás',
    'Kanapé',
    'Fotel',
    'Szék',
    'Matrac',
    'Kárpittisztítás',
  ],
  'Lefolyótisztítás': ['Kiszállás', 'Lefolyótisztítás', 'Duguláselhárítás'],
};

List<String> pricingUnitsFor(String service, String item) {
  if (item == 'Kazántisztítás' || item == 'Konvektortisztítás') {
    return const ['Ft/alkalom', 'Egyedi árajánlat'];
  }
  if (item == 'Klímatisztítás') {
    return const ['Ft/egység', 'Ft/alkalom', 'Egyedi árajánlat'];
  }
  if (item == 'Szerelés' || item == 'Klímajavítás') {
    return const ['Ft/óra', 'Ft/alkalom', 'Egyedi árajánlat'];
  }
  if (service == 'Bútorösszeszerelés' && item == 'Bútorösszeszerelés') {
    return const ['Ft/óra', 'Ft/alkalom', '%', 'Egyedi árajánlat'];
  }
  if (item == 'Kiszállás') return const ['Ft/alkalom', 'Egyedi árajánlat'];
  if (item == 'Ágyneműmosás' || item == 'Bértextília') {
    return const ['Ft/fő', 'Ft/kg', 'Ft/darab', 'Egyedi árajánlat'];
  }
  if (item == 'Mosás' || item == 'Vasalás') {
    return const [
      'Ft/kg',
      'Ft/fő',
      'Ft/darab',
      'Ft/óra',
      'Ft/alkalom',
      'Egyedi árajánlat',
    ];
  }
  if (service == 'Apartmantakarítás' || service.contains('takarítás')) {
    return const [
      'Ft/m²-sáv',
      'Ft/m²',
      'Ft/óra',
      'Ft/alkalom',
      'Egyedi árajánlat',
    ];
  }
  if (service == 'Mosodai szolgáltatás') {
    return const [
      'Ft/kg',
      'Ft/fő',
      'Ft/darab',
      'Ft/alkalom',
      'Egyedi árajánlat',
    ];
  }
  return const ['Ft/óra', 'Ft/alkalom', 'Ft/darab', 'Egyedi árajánlat'];
}

bool serviceNeedsPermitWarning(String? service) =>
    service == 'Villanyszerelés' || service == 'Gázszerelés';
