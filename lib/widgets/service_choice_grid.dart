import 'package:flutter/material.dart';

import '../theme.dart';

const serviceChoices = [
  {"name": "Apartmantakarítás", "image": "assets/service_icons/service_00.png"},
  {
    "name": "Mosodai szolgáltatás",
    "image": "assets/service_icons/service_08.png",
  },
  {
    "name": "Általános takarítás",
    "image": "assets/service_icons/service_01.png",
  },
  {"name": "Nagytakarítás", "image": "assets/service_icons/service_02.png"},
  {
    "name": "Felújítás utáni takarítás",
    "image": "assets/service_icons/service_02.png",
  },
  {"name": "Vízszerelés", "image": "assets/service_icons/service_03.png"},
  {"name": "Gázszerelés", "image": "assets/service_icons/service_04.png"},
  {"name": "Villanyszerelés", "image": "assets/service_icons/service_05.png"},
  {"name": "Karbantartás", "image": "assets/service_icons/service_05.png"},
  {
    "name": "Klímatisztítás és -javítás",
    "image": "assets/service_icons/service_06.png",
  },
  {
    "name": "Bútorösszeszerelés",
    "image": "assets/service_icons/service_07.png",
  },
  {"name": "Kárpittisztítás", "image": "assets/service_icons/service_02.png"},
  {"name": "Lefolyótisztítás", "image": "assets/service_icons/service_03.png"},
];

String serviceImage(String name) => serviceChoices.firstWhere(
  (entry) => entry['name'] == name,
  orElse: () => serviceChoices.first,
)['image']!;

class ServiceChoiceGrid extends StatelessWidget {
  final String? selected;
  final bool compact;
  final ValueChanged<String> onSelected;
  const ServiceChoiceGrid({
    super.key,
    this.selected,
    this.compact = false,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(12) > 14.4;
      final columns = largeText || constraints.maxWidth < 310 ? 2 : 3;
      final tileHeight = largeText
          ? 112.0
          : compact
          ? 84.0
          : 84.0;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: serviceChoices.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: tileHeight,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) {
          final entry = serviceChoices[index];
          final name = entry['name']!;
          final active = selected == name;
          final label = switch (name) {
            'Apartmantakarítás' => 'Apartman-\ntakarítás',
            'Bútorösszeszerelés' => 'Bútor-\nösszeszerelés',
            'Felújítás utáni takarítás' => 'Felújítás utáni\ntakarítás',
            'Klímatisztítás és -javítás' => 'Klímatisztítás\nés -javítás',
            'Kárpittisztítás' => 'Kárpit-\ntisztítás',
            'Lefolyótisztítás' => 'Lefolyó-\ntisztítás',
            _ => name,
          };
          return Semantics(
            label: name,
            selected: active,
            button: true,
            child: Material(
              color: active
                  ? takiTeal
                  : index.isEven
                  ? takiMint
                  : takiYellowSoft,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: ValueKey('service-option-$name'),
                onTap: () => onSelected(name),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              entry['image']!,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 11 : 12,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : takiNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (active)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
