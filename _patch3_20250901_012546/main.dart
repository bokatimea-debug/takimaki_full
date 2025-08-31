import 'screens/provider_offer_reply_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_login_screen.dart';
import 'screens/role_select_screen.dart';

import 'screens/customer_profile_screen.dart';
import 'screens/customer_edit_profile_screen.dart';
import 'screens/customer_search_screen.dart';
import 'screens/customer_orders_screen.dart';
import 'screens/customer_messages_screen.dart';

import 'screens/offers_screen.dart';
import 'screens/chat_screens.dart';

import 'screens/provider_profile_screen.dart';
import 'screens/provider_edit_profile_screen.dart';
import 'screens/provider_services_screen.dart';
import 'screens/provider_add_service_screen.dart';
import 'screens/provider_requests_screen.dart';
import 'screens/provider_messages_screen.dart';
import 'screens/provider_all_orders_screen.dart';

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
        colorSchemeSeed: const Color(0xFF00ACC1),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('hu'),
        Locale('en'),
      ],
      locale: const Locale('hu'),
      home: const SplashLoginScreen(),
      routes: <String, WidgetBuilder>{
        '/role_select': (_) => const RoleSelectScreen(),

        '/customer/profile':      (_) => const CustomerProfileScreen(),
        '/customer/edit_profile': (_) => const CustomerEditProfileScreen(),
        '/customer/search':       (_) => const CustomerSearchScreen(),
        '/customer/orders':       (_) => const CustomerOrdersScreen(),
        '/customer/messages':     (_) => const CustomerMessagesScreen(),

        '/offers': (_) => const OffersScreen(),
        '/chat':   (_) => const ChatListScreen(),

        '/provider/profile':      (_) => const ProviderProfileScreen(),
        '/provider/edit_profile': (_) => const ProviderEditProfileScreen(),
        '/provider/services':     (_) => const ProviderServicesScreen(),
        '/provider/add_service':  (_) => const ProviderAddServiceScreen(),
        '/provider/requests':     (_) => const ProviderRequestsScreen(),
        '/provider/messages':     (_) => const ProviderMessagesScreen(),
        '/provider/all_orders':   (_) => const ProviderAllOrdersScreen(),

        '/map_picker': (_) => const MapPickerScreen(),
      },
    );
  }
}




