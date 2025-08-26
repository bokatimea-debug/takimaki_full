import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';
import 'screens/customer_search_screen.dart';
import 'screens/provider_profile_setup_screen.dart';

void main() => runApp(const TakimakiApp());

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00B8B8));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Takimaki',
      theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
      home: const RoleSelectScreen(),
      routes: {
        '/customer/search': (context) => const CustomerSearchScreen(),
        '/provider/setup': (context) => const ProviderProfileSetupScreen(),
      },
    );
  }
}
