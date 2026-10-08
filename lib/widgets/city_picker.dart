import 'package:flutter/material.dart';

import '../data/hungarian_cities.dart';
import '../theme.dart';

Future<String?> showCityPicker(
  BuildContext context, {
  required String selectedCity,
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: takiCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CityPicker(selectedCity: selectedCity),
    );

class _CityPicker extends StatefulWidget {
  const _CityPicker({required this.selectedCity});

  final String selectedCity;

  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _query = '';

  String _searchable(String value) {
    var result = value.toLowerCase().trim();
    const accented = 'áéíóöőúüű';
    const plain = 'aeiooouuu';
    for (var i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], plain[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final typedCity = _query.trim();
    final canUseTypedCity = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿŐőŰű .'-]+$")
            .hasMatch(typedCity) &&
        RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿŐőŰű]').allMatches(typedCity).length >= 2 &&
        !hungarianCities.any(
          (city) => _searchable(city) == _searchable(typedCity),
        );
    final choices = <String>{
      ...hungarianCities,
      if (widget.selectedCity.trim().isNotEmpty) widget.selectedCity,
    }.where((city) => _searchable(city).contains(_searchable(_query))).toList();
    return FractionallySizedBox(
      heightFactor: MediaQuery.viewInsetsOf(context).bottom > 0 ? 1 : .8,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Válassz várost',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: takiNavy,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bezárás',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const ValueKey('city-search'),
                  onChanged: (value) => setState(() => _query = value),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Város keresése',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: choices.isEmpty && !canUseTypedCity
                      ? const Center(
                          child: Text('Nincs ilyen város a listában.'))
                      : ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: choices.length + (canUseTypedCity ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (canUseTypedCity && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  key: const ValueKey('city-use-typed'),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  leading: const Icon(
                                    Icons.add_location_alt_outlined,
                                  ),
                                  title: Text(typedCity),
                                  tileColor: takiMint,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  onTap: () =>
                                      Navigator.pop(context, typedCity),
                                ),
                              );
                            }
                            final city =
                                choices[index - (canUseTypedCity ? 1 : 0)];
                            final selected = city == widget.selectedCity;
                            return ListTile(
                              key: ValueKey('city-option-$city'),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              title: Text(city),
                              leading: const Icon(Icons.location_city_outlined),
                              trailing: selected
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: takiTeal)
                                  : null,
                              selected: selected,
                              selectedColor: takiNavy,
                              selectedTileColor: takiMint,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              onTap: () => Navigator.pop(context, city),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
