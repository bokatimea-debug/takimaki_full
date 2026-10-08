import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/main.dart';

void main() {
  testWidgets('A Takimaki bejelentkezési képernyő betölt', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TakimakiApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('TakiMaki'), findsOneWidget);
    expect(find.text('Kezdés'), findsOneWidget);
  });
}
