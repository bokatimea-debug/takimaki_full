import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../utils/profile_photo_loader.dart';
import '../widgets/onboarding_components.dart';
import 'phone_number_screen.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final lastCtrl = TextEditingController();
  final firstCtrl = TextEditingController();
  File? photo;
  bool _saving = false;

  Future<void> _pick() async {
    final selected = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 88,
    );
    if (selected != null && mounted) {
      setState(() => photo = File(selected.path));
    }
  }

  bool get _canContinue =>
      lastCtrl.text.trim().isNotEmpty &&
      firstCtrl.text.trim().isNotEmpty &&
      photo != null;

  Future<void> _next() async {
    if (!_canContinue || _saving) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_last_name', lastCtrl.text.trim());
      await prefs.setString('registration_first_name', firstCtrl.text.trim());
      await prefs.setString('customer_last_name', lastCtrl.text.trim());
      await prefs.setString('customer_first_name', firstCtrl.text.trim());
      await ProfilePhotoLoader.saveRegistrationPhoto(photo!);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhoneNumberScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A mentés nem sikerült. Próbáld újra.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    lastCtrl.dispose();
    firstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profil létrehozása')),
        body: OnboardingBody(
          children: [
            const OnboardingSteps(current: 0),
            const OnboardingHeading(
              title: 'Ismerjünk meg!',
              subtitle: 'Add meg a nevedet, és válassz egy profilképet.',
            ),
            OnboardingCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Profilkép kiválasztása',
                        child: GestureDetector(
                          onTap: _saving ? null : _pick,
                          child: SizedBox.square(
                            dimension: 88,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: takiMint,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: photo == null
                                      ? const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 32,
                                          color: takiNavy,
                                        )
                                      : Image.file(photo!, fit: BoxFit.cover),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: takiOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                    color: takiNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'A profilképed',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Koppints a kamerára a kép kiválasztásához.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: takiMint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: lastCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    style: const TextStyle(fontSize: 16, color: takiNavy),
                    decoration: onboardingField(
                      label: 'Vezetéknév *',
                      icon: Icons.badge_outlined,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: firstCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.givenName],
                    style: const TextStyle(fontSize: 16, color: takiNavy),
                    decoration: onboardingField(
                      label: 'Keresztnév *',
                      icon: Icons.person_outline,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            OnboardingButton(
              label: 'Tovább',
              onPressed: _canContinue ? _next : null,
              loading: _saving,
            ),
          ],
        ),
      );
}
