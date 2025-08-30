// lib/utils/district_utils.dart
String romanFromDistrict(int n) {
  const romans = {
    1:"I",2:"II",3:"III",4:"IV",5:"V",6:"VI",7:"VII",8:"VIII",9:"IX",10:"X",
    11:"XI",12:"XII",13:"XIII",14:"XIV",15:"XV",16:"XVI",17:"XVII",18:"XVIII",19:"XIX",20:"XX",21:"XXI",22:"XXII",23:"XXIII"
  };
  return romans[n] ?? "$n.";
}

/// Budapest irányítószám → kerület (pl. 1137 -> XIII)
/// Egyszerű szabály: ha 1xxx, akkor a középső két szám a kerület (01..23)
String? districtFromPostal(String postal) {
  if (postal.length != 4) return null;
  if (!postal.startsWith("1")) return null;
  final num = int.tryParse(postal.substring(1,3));
  if (num == null || num < 1 || num > 23) return null;
  return romanFromDistrict(num);
}
