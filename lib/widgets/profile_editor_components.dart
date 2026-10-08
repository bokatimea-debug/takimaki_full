import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/profile_photo_loader.dart';

class ProfileEditorBody extends StatelessWidget {
  const ProfileEditorBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Text(
              'Bemutatkozás és működési terület.',
              style: TextStyle(fontSize: 14, color: takiMutedText),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    ),
  );
}

class ProfileEditorCard extends StatelessWidget {
  const ProfileEditorCard({
    super.key,
    required this.firstName,
    required this.photo,
    required this.bio,
    required this.city,
    required this.onPickPhoto,
    required this.onPickCity,
    this.enabled = true,
  });

  final String firstName;
  final ImageProvider? photo;
  final TextEditingController bio;
  final String city;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickCity;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('profile-editor-card'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: takiProfileGradient,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'Profilkép módosítása',
          child: InkWell(
            onTap: enabled ? onPickPhoto : null,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ProfileAvatar(
                        background: photo,
                        radius: 25,
                        childWhenEmpty: const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: takiNavy,
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: takiOrange,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: takiNavy,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName.isEmpty ? 'Saját profil' : firstName,
                        key: const ValueKey('profile-header-name'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Profilkép módosítása',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Bemutatkozás',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('profile-bio'),
          controller: bio,
          enabled: enabled,
          minLines: 2,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Néhány szó rólad…',
            isDense: true,
            fillColor: takiFieldSurface,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: takiFieldSurface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            key: const ValueKey('profile-city'),
            onTap: enabled ? onPickCity : null,
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: takiNavy,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Működési terület',
                            style: TextStyle(
                              color: takiMutedText,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            city,
                            style: const TextStyle(
                              color: takiNavy,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.expand_more_rounded, color: takiNavy),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ProfileEditorActions extends StatelessWidget {
  const ProfileEditorActions({
    super.key,
    required this.onSave,
    this.busy = false,
    this.enabled = true,
  });

  final VoidCallback onSave;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 12),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: takiOrange,
          foregroundColor: takiNavy,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        onPressed: enabled && !busy ? onSave : null,
        child: Text(busy ? 'Mentés…' : 'Módosítások mentése'),
      ),
    ],
  );
}
