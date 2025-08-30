import 'package:flutter/material.dart';
import 'screens/splash_login_screen.dart';
import 'screens/role_select_screen.dart';

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
        '/customer/profile': (context) => const _PlaceholderScreen(title: 'Customer Profile'),
        '/provider/profile': (context) => const _PlaceholderScreen(title: 'Provider Profile'),
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title képernyő (helyőrző)')),
    );
  }
}
