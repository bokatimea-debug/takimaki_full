// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_login_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/provider_profile_screen.dart';
import 'screens/provider_services_screen.dart';
import 'screens/provider_add_service_screen.dart';
import 'screens/provider_edit_profile_screen.dart';

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
        colorSchemeSeed: const Color(0xFF0FA3A9),
        useMaterial3: true,
      ),
      home: const SplashLoginScreen(),
      routes: {
        '/role_select': (context) => const RoleSelectScreen(),
        '/customer/profile': (context) => const CustomerProfileScreen(),
        '/provider/profile': (context) => const ProviderProfileScreen(),
        '/provider/services': (context) => const ProviderServicesScreen(),
        '/provider/add_service': (context) => const ProviderAddServiceScreen(),
        '/provider/edit_profile': (context) => const ProviderEditProfileScreen(),
        // később: /provider/requests, /provider/messages, /provider/all_orders
      },
    );
  }
}
