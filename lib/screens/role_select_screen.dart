import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString('customer_last_name') ?? '';
    final firstName = prefs.getString('customer_first_name') ?? '';
    final photoPath = prefs.getString('registration_photo_path') ?? '';

    await prefs.setString('active_role', role);
    if (role == 'provider') {
      if (lastName.isNotEmpty) {
        await prefs.setString('provider_last_name', lastName);
      }
      if (firstName.isNotEmpty) {
        await prefs.setString('provider_first_name', firstName);
      }
      if (photoPath.isNotEmpty) {
        await prefs.setString('provider_photo_path', photoPath);
      }
    }

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      role == 'provider' ? '/provider/profile' : '/customer/profile',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szerepválasztó')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectRole(context, 'provider'),
                child: Card(
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_repair_service, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Szolgáltatást kínálok',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _selectRole(context, 'customer'),
                child: Card(
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Szolgáltatást rendelek',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
