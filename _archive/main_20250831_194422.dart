import 'screens/offers_screen.dart';
import 'screens/chat_screens.dart';
import 'screens/customer_edit_profile_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/provider_edit_profile_screen.dart';
import 'screens/provider_profile_screen.dart';
import "package:flutter/material.dart";
import "screens/splash_login_screen.dart";
import "screens/role_select_screen.dart";
import "screens/customer_profile_screen.dart";
import "screens/customer_edit_profile_screen.dart";
import "screens/customer_search_screen.dart";
import "screens/customer_orders_screen.dart";
import "screens/customer_messages_screen.dart";
import "screens/offers_screen.dart";
import "screens/chat_demo_screen.dart";
import "screens/provider_profile_screen.dart";
import "screens/provider_edit_profile_screen.dart";
import "screens/provider_services_screen.dart";
import "screens/provider_add_service_screen.dart";
import "screens/provider_requests_screen.dart";
import "screens/provider_messages_screen.dart";
import "screens/provider_all_orders_screen.dart";
import "screens/map_picker_screen.dart";



void main() {
  runApp(const TakimakiApp());
}

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Takimaki",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00ACC1),
        useMaterial3: true,
      ),
      home: const SplashLoginScreen(),
      routes: {
      },
    );
  }
}








