import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps normal Back navigation and provides an explicit one-tap main menu.
class TakiAppBar extends AppBar {
  TakiAppBar({super.key, required Widget title, double? titleSpacing})
    : super(
        title: title,
        titleSpacing: titleSpacing,
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Főmenü',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => goToMainMenu(context),
            ),
          ),
        ],
      );
}

Future<void> goToMainMenu(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return;
  final route = ModalRoute.of(context);
  final args = route?.settings.arguments;
  final role = args is Map && args['view_role'] != null
      ? args['view_role'].toString()
      : (route?.settings.name?.startsWith('/provider/') == true
            ? 'provider'
            : prefs.getString('active_role') ?? 'customer');
  final target = role == 'provider' ? '/provider/profile' : '/customer/profile';
  final navigator = Navigator.of(context);
  var found = false;
  navigator.popUntil((route) {
    found = route.settings.name == target;
    return found || route.isFirst;
  });
  if (!found) navigator.pushReplacementNamed(target);
}
