import 'package:takimaki_full/widgets/branded_background.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/screens/customer_search_screen.dart';
import 'package:takimaki_full/screens/customer_orders_screen.dart';
import 'package:takimaki_full/screens/offers_screen.dart';
import 'package:takimaki_full/screens/order_details_screen.dart';
import 'package:takimaki_full/screens/provider_requests_screen.dart';
import 'package:takimaki_full/screens/provider_offer_reply_screen.dart';
import 'package:takimaki_full/screens/settings_screen.dart';
import 'package:takimaki_full/screens/customer_edit_profile_screen.dart';
import 'package:takimaki_full/screens/provider_edit_profile_screen.dart';
import 'package:takimaki_full/theme.dart';

const captureKey = ValueKey('capture');
final nav = GlobalKey<NavigatorState>();
final future = DateTime.now().add(const Duration(days: 2));
Map<String, dynamic> order() => {
  'id': 'r1',
  'request_id': 'r1',
  'service': 'Általános takarítás',
  'customer': 'Boka Tímea',
  'provider_name': 'Nagy Petra',
  'date': future.toIso8601String().split('T').first,
  'time': '12:00',
  'address': 'Budapest, Váci utca 19',
  'price': 14500,
  'status': 'Elfogadva',
  'note': 'Az időpont megfelelő, az eszközöket viszem.',
  'view_role': 'provider',
  'created_at': DateTime.now().toIso8601String(),
};

Future<void> showApp(
  WidgetTester tester, {
  Size size = const Size(360, 740),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: nav,
      theme: takimakiTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 24, bottom: 48),
          viewPadding: const EdgeInsets.only(top: 24, bottom: 48),
          textScaler: TextScaler.linear(scale),
        ),
        child: RepaintBoundary(
          key: captureKey,
          child: BrandedBackground(child: child!),
        ),
      ),
      initialRoute: '/customer/profile',
      routes: {
        '/customer/profile': (_) =>
            const Scaffold(body: Text('Megrendelő főmenü')),
        '/provider/profile': (_) =>
            const Scaffold(body: Text('Szolgáltató főmenü')),
        '/customer/search': (_) => const CustomerSearchScreen(),
        '/customer/orders': (_) => const CustomerOrdersScreen(),
        '/offers': (_) => const OffersScreen(),
        '/order/details': (_) => const OrderDetailsScreen(),
        '/provider/requests': (_) => const ProviderRequestsScreen(),
        '/provider/offer_reply': (_) => const ProviderOfferReplyScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/customer/edit_profile': (_) => const CustomerEditProfileScreen(),
        '/provider/edit_profile': (_) => const ProviderEditProfileScreen(),
      },
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/customer/profile'),
          builder: (_) => const Scaffold(body: Text('Megrendelő főmenü')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

InlineSpan _fontSpan(InlineSpan span) {
  if (span is! TextSpan) return span;
  final style = span.style;
  final replace = style?.fontFamily == null || style?.fontFamily == 'Ahem';
  return TextSpan(
    text: span.text,
    style: replace
        ? (style ?? const TextStyle()).copyWith(fontFamily: 'Roboto')
        : style,
    children: span.children?.map(_fontSpan).toList(),
    recognizer: span.recognizer,
    semanticsLabel: span.semanticsLabel,
  );
}

void _useLoadedTestFonts(WidgetTester tester) {
  void visit(Element element) {
    final render = element.renderObject;
    if (render is RenderParagraph) render.text = _fontSpan(render.text);
    if (render is RenderEditable && render.text != null)
      render.text = _fontSpan(render.text!);
    element.visitChildren(visit);
  }

  tester.element(find.byType(MaterialApp)).visitChildren(visit);
}

Future<void> capture(WidgetTester tester, String name) async {
  final dir = Platform.environment['TAKIMAKI_CAPTURE'];
  if (dir == null) return;
  _useLoadedTestFonts(tester);
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(captureKey))
        .toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(dir).create(recursive: true);
    await File('$dir/$name.png').writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    final loader = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium', 'Bold', 'Black']) {
      final file = File(
        '$sdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
      );
      if (file.existsSync())
        loader.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
    }
    await loader.load();
    final fallback = FontLoader('Ahem');
    for (final weight in ['Regular', 'Medium', 'Bold', 'Black']) {
      final file = File(
        '$sdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
      );
      if (file.existsSync())
        fallback.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
    }
    await fallback.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'active_role': 'customer',
      'customer_first_name': 'Tímea',
      'customer_last_name': 'Boka',
      'provider_services': jsonEncode([
        {'name': 'Általános takarítás'},
      ]),
    }),
  );
  testWidgets(
    'Saved request removes the completed form; offers Back returns home',
    (tester) async {
      await showApp(tester);
      nav.currentState!.pushNamed('/customer/search');
      await tester.pumpAndSettle();
            await tester.tap(
        find.byKey(const ValueKey('customer-service-selector')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('service-option-Általános takarítás')),
      );
      await tester.pumpAndSettle();
      final address = find.widgetWithText(TextField, 'Cím kiválasztása');
      await tester.scrollUntilVisible(
        address,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(address, 'Budapest, Váci 19');
      await tester.ensureVisible(
        find.widgetWithText(TextField, 'Alapterület (m²)'),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Alapterület (m²)'),
        '65',
      );
      await tester.ensureVisible(find.text('Válassz dátumot'));
      await tester.tap(find.text('Válassz dátumot'));
      await tester.pumpAndSettle();
      nav.currentState!.pop(future);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kezdés'));
      await tester.pumpAndSettle();
      nav.currentState!.pop(const TimeOfDay(hour: 12, minute: 0));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Befejezés: 14:00'));
      await tester.tap(find.text('Befejezés: 14:00'));
      await tester.pumpAndSettle();
      nav.currentState!.pop(const TimeOfDay(hour: 13, minute: 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajánlatok kérése'));
      await tester.pumpAndSettle();
      expect(find.byType(OffersScreen), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(
        jsonDecode(prefs.getString('provider_requests')!) as List,
        hasLength(1),
      );
      expect(prefs.getString('customer_offers'), isNull);
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Megrendelő főmenü'), findsOneWidget);
      expect(find.byType(CustomerSearchScreen), findsNothing);
    },
  );
  testWidgets('Direct home clears nested customer routes', (tester) async {
    await showApp(tester);
    nav.currentState!.pushNamed('/customer/orders');
    await tester.pumpAndSettle();
    nav.currentState!.pushNamed(
      '/order/details',
      arguments: {...order(), 'view_role': 'customer'},
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Főmenü'));
    await tester.pumpAndSettle();
    expect(find.text('Megrendelő főmenü'), findsOneWidget);
    expect(nav.currentState!.canPop(), isFalse);
  });
  testWidgets(
    'Provider home goes to provider dashboard even from a shared screen',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_role', 'provider');
      await showApp(tester);
      nav.currentState!.pushReplacementNamed('/provider/profile');
      await tester.pumpAndSettle();
      nav.currentState!.pushNamed('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Főmenü'));
      await tester.pumpAndSettle();
      expect(find.text('Szolgáltató főmenü'), findsOneWidget);
      expect(nav.currentState!.canPop(), isFalse);
    },
  );
  for (final role in ['customer', 'provider']) {
    testWidgets('Deletion exists in Settings and not $role profile editor', (
      tester,
    ) async {
      await showApp(tester);
      nav.currentState!.pushNamed('/$role/edit_profile');
      await tester.pumpAndSettle();
      expect(find.text('Profil törlése'), findsNothing);
      nav.currentState!.pop();
      nav.currentState!.pushNamed('/settings');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Profil törlése'));
      await tester.tap(find.text('Profil törlése'));
      await tester.pumpAndSettle();
      expect(find.textContaining('3 hónap'), findsOneWidget);
      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();
      expect(
        (await SharedPreferences.getInstance()).getString(
          'customer_first_name',
        ),
        'Tímea',
      );
    });
  }
  testWidgets(
    'Matching new request has a working send action and persists real offer',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'provider_requests',
        jsonEncode([
          {...order(), 'status': 'pending'},
          {
            ...order(),
            'id': 'other',
            'request_id': 'other',
            'service': 'Villanyszerelés',
            'status': 'pending',
          },
        ]),
      );
      await showApp(tester);
      nav.currentState!.pushNamed('/provider/requests');
      await tester.pumpAndSettle();
      expect(find.text('Villanyszerelés'), findsNothing);
      expect(find.textContaining('Boka'), findsNothing);
      await tester.tap(find.text('Ajánlat küldése'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Ajánlott ár (Ft)'),
        '14500',
      );
      await tester.ensureVisible(find.text('Ajánlat elküldése'));
      await tester.tap(find.text('Ajánlat elküldése'));
      await tester.pumpAndSettle();
      expect(find.text('Ajánlat módosítása'), findsOneWidget);
      expect(
        (jsonDecode(
          prefs.getString('customer_offers')!,
        ) as List).single['price'],
        14500,
      );
      await tester.tap(find.text('Ajánlat módosítása'));
      await tester.pumpAndSettle();
      expect(find.text('Ajánlat módosítása'), findsOneWidget);
      expect(find.text('14500'), findsOneWidget);
      expect(
        (jsonDecode(prefs.getString('workflow_notifications')!) as List)
            .single['title'],
        'Új ajánlat érkezett',
      );
    },
  );
  for (final size in [
    const Size(360, 740),
    const Size(412, 892),
    const Size(320, 640),
  ]) {
    testWidgets('Order controls remain reachable at $size', (tester) async {
      await showApp(tester, size: size, scale: size.width == 320 ? 1.3 : 1);
      nav.currentState!.pushNamed('/order/details', arguments: order());
      await tester.pumpAndSettle();
      expect(find.text('Tímea'), findsOneWidget);
      expect(find.text('Boka Tímea'), findsNothing);
      final cancel = find.text('Rendelés lemondása');
      await tester.scrollUntilVisible(
        cancel,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(cancel.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, 'order_details_${size.width.toInt()}');
    });
  }
}
