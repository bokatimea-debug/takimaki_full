import 'screens/provider_offer_reply_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_login_screen.dart';
import 'screens/role_select_screen.dart';

import 'screens/customer_profile_screen.dart';
import 'screens/customer_edit_profile_screen.dart';
import 'screens/customer_search_screen.dart';
import 'screens/customer_orders_screen.dart';

import 'screens/offers_screen.dart';
import 'screens/chat_screens.dart';

import 'screens/provider_profile_screen.dart';
import 'screens/provider_edit_profile_screen.dart';
import 'screens/provider_services_screen.dart';
import 'screens/provider_add_service_screen.dart';
import 'screens/provider_requests_screen.dart';
import 'screens/provider_all_orders_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subscription_screen.dart';

import 'screens/map_picker_screen.dart';

void main() {
  runApp(const TakimakiApp());
}

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takimaki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0FA3A9),
          primary: const Color(0xFF0FA3A9),
          secondary: const Color(0xFFFF8C42),
          surface: const Color(0xFFFAFCFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAFA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7FAFA),
          foregroundColor: Color(0xFF13282B),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0x14000000)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0x22000000)),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('hu'), Locale('en')],
      locale: const Locale('hu'),
      home: const SplashLoginScreen(),
      routes: <String, WidgetBuilder>{
        '/welcome': (_) => const SplashLoginScreen(),
        '/role_select': (_) => const RoleSelectScreen(),

        '/customer/profile': (_) => const CustomerProfileScreen(),
        '/customer/edit_profile': (_) => const CustomerEditProfileScreen(),
        '/customer/search': (_) => const CustomerSearchScreen(),
        '/customer/orders': (_) => const CustomerOrdersScreen(),
        '/customer/messages': (_) => const ChatListScreen(),

        '/offers': (_) => const OffersScreen(),
        '/chat': (_) => const ChatListScreen(),

        '/provider/profile': (_) => const ProviderProfileScreen(),
        '/provider/edit_profile': (_) => const ProviderEditProfileScreen(),
        '/provider/services': (_) => const ProviderServicesScreen(),
        '/provider/add_service': (_) => const ProviderAddServiceScreen(),
        '/provider/requests': (_) => const ProviderRequestsScreen(),
        '/provider/offer_reply': (_) => const ProviderOfferReplyScreen(),
        '/provider/messages': (_) => const ChatListScreen(),
        '/provider/all_orders': (_) => const ProviderAllOrdersScreen(),

        '/map_picker': (_) => const MapPickerScreen(),
        '/order/details': (_) => const OrderDetailsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/subscriptions': (_) => const SubscriptionScreen(),
      },
    );
  }
}
