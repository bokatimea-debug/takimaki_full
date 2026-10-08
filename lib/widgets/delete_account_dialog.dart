import 'package:flutter/material.dart';

import '../screens/splash_login_screen.dart';
import '../services/account_store.dart';

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Profil törlése'),
      content: const Text(
        'A törlés mindkét profilodat és a mentett adataidat érinti. '
        'Ezzel a telefonszámmal 3 hónapig nem regisztrálhatsz újra. '
        'Biztosan törlöd a profilodat?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Mégse'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          child: const Text('Profil törlése'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await AccountStore.deleteAccount();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashLoginScreen()),
      (_) => false,
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A törlés nem sikerült. Próbáld újra.')),
    );
  }
}
