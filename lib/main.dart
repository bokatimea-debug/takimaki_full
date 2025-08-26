import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/customer_search_screen.dart';
import 'screens/provider_profile_setup_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/offers_demo_screen.dart';
import 'screens/moderation_demo_screen.dart';
import 'screens/chat_demo_screen.dart';

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
      home: const SplashScreen(),
      routes: {
        '/customer/search': (context) => const CustomerSearchScreen(),
        '/customer/profile': (context) => const CustomerProfileScreen(),
        '/provider/setup': (context) => const ProviderProfileSetupScreen(),
        '/offers/demo': (context) => const OffersDemoScreen(),
        '/moderation/demo': (context) => const ModerationDemoScreen(),
        '/chat/demo': (context) => const ChatDemoScreen(),
      },
    );
  }
}
