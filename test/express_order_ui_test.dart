import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/screens/customer_search_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('expressz rendelés uses the approved customer-facing name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(home: CustomerSearchScreen(startAsSos: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expressz rendelés'), findsWidgets);
    expect(find.text('Expressz rendelés feltételei'), findsOneWidget);
    expect(find.text('SOS segítség'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
