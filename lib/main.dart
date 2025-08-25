import 'package:flutter/material.dart';
import 'utils.dart';
import 'screens/onboarding.dart';
import 'screens/role_select.dart';
import 'screens/home.dart';

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
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/role': (_) => const RoleSelectScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
