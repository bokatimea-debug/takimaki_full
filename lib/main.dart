// lib/main.dart
import 'package:flutter/material.dart';

import 'utils.dart';
import 'screens/role_select.dart';
import 'screens/customer_search_screen.dart';
import 'screens/provider_profile_setup_screen.dart';
import 'screens/home.dart'; // ha hivatkozol rá máshol

void main() => runApp(const TakimakiApp());

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: takimakiTurquoise);
    return MaterialApp(
      title: 'Takimaki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme.copyWith(
          primary: takimakiTurquoise,
          secondary: takimakiOrange,
        ),
        useMaterial3: true,
      ),
      home: RoleSelectScreen(),
      routes: {
        '/customer/search': (context) => const CustomerSearchScreen(),
        '/provider/setup': (context) => const ProviderProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

