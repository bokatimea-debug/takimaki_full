import 'package:flutter/material.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Válassz szerepkört')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // ide majd a Megrendelő képernyő jön
              },
              child: const Text('Megrendelő'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // ide majd a Szolgáltató képernyő jön
              },
              child: const Text('Szolgáltató'),
            ),
          ],
        ),
      ),
    );
  }
}
