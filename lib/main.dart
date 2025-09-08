import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/role_select_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/provider_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TakimakiApp());
}

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takimaki',
      debugShowCheckedModeBanner: false,
      initialRoute: '/role_select',
      routes: <String, WidgetBuilder>{
        '/role_select':           (_) => const RoleSelectScreen(),
        '/customer/profile':      (_) => const CustomerProfileScreen(),
        '/provider/profile':      (_) => const ProviderProfileScreen(),
      },
    );
  }
}
