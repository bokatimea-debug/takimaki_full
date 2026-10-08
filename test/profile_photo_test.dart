import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/utils/profile_photo_loader.dart';

const photoFixture =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aT1kAAAAASUVORK5CYII=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Picked photo survives deletion of the image picker file in both roles',
      () async {
    final dir = await Directory.systemTemp.createTemp('takimaki_photo_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/photo.png');
    await file.writeAsBytes(base64Decode(photoFixture));
    await ProfilePhotoLoader.saveFromPath(file.path, role: 'provider');
    await file.delete();
    for (final role in ['provider', 'customer']) {
      final image = await ProfilePhotoLoader.loadAny(role: role);
      expect(image, isA<MemoryImage>());
      expect((image as MemoryImage).bytes, base64Decode(photoFixture));
    }
  });

  test('Registration image is persisted before the temporary file expires',
      () async {
    final dir =
        await Directory.systemTemp.createTemp('takimaki_registration_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/photo.png');
    await file.writeAsBytes(base64Decode(photoFixture));
    await ProfilePhotoLoader.saveRegistrationPhoto(file);
    await file.delete();
    expect(await ProfilePhotoLoader.loadAny(), isA<MemoryImage>());
  });

  test('Legacy role-specific photos are supported', () async {
    SharedPreferences.setMockInitialValues(
        {'provider_profile_photo_b64': photoFixture});
    expect(
        await ProfilePhotoLoader.loadAny(role: 'provider'), isA<MemoryImage>());
  });

  test('Persisted bytes take precedence over stale temporary paths', () async {
    SharedPreferences.setMockInitialValues({
      'profile_photo_b64': photoFixture,
      'customer_photo_path': '/file/that/no/longer/exists.png',
    });
    expect(
        await ProfilePhotoLoader.loadAny(role: 'customer'), isA<MemoryImage>());
  });
}
