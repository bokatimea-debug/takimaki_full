import 'package:flutter/material.dart';
import 'screens/role_select.dart';  // helyes útvonal

void main() {
  runApp(const TakimakiApp());
}

class TakimakiApp extends StatelessWidget {
  const TakimakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Takimaki',
      // Induláskor a RoleSelectScreen nyíljon meg
      initialRoute: '/role',
      routes: {
        '/role': (_) => const RoleSelectScreen(),
      },
    );
  }
}

