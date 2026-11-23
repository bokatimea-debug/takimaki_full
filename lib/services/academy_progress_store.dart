import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_backend.dart';

/// Guest-safe academy state. Guests never need authentication: their data stays
/// on-device and can be erased. A signed-in Firebase account receives a
/// best-effort copy of progress; official exam verification remains server-side.
class AcademyProgressStore {
  static const _completedKey = 'academy_completed_modules_v1';
  static const _attemptsKey = 'academy_exam_attempts_v1';

  static Future<Set<int>> completedModules() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> completeModule(int moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await completedModules();
    completed.add(moduleId);
    await prefs.setStringList(_completedKey, completed.map((id) => '$id').toList());
    await _syncProgress(completed);
  }

  static Future<void> saveAttempt({
    required int correctCount,
    required int percentage,
    required int grade,
    required bool passed,
    required List<int> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = List<Map<String, dynamic>>.from(
      (jsonDecode(prefs.getString(_attemptsKey) ?? '[]') as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final attempt = <String, dynamic>{
      'completedAt': DateTime.now().toIso8601String(),
      'correctCount': correctCount,
      'percentage': percentage,
      'grade': grade,
      'passed': passed,
      'answers': answers,
      'examVersion': 1,
    };
    attempts.add(attempt);
    await prefs.setString(_attemptsKey, jsonEncode(attempts));

    final backend = FirebaseBackend.instance;
    if (backend.isAvailable && backend.uid != null) {
      try {
        await backend.firestore
            .collection('academy_exam_attempts')
            .doc('${backend.uid}_${DateTime.now().microsecondsSinceEpoch}')
            .set({...attempt, 'userId': backend.uid, 'source': 'client_pending_verification'});
      } catch (_) {
        // Local attempt remains available while offline.
      }
    }
  }

  /// The most recent local result is shown again on the Academy home screen.
  /// It remains available after an app restart until the learner deletes local
  /// learning data.
  static Future<Map<String, dynamic>?> latestAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final list = (jsonDecode(prefs.getString(_attemptsKey) ?? '[]') as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
      return list.isEmpty ? null : list.last;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> submitForOfficialVerification(
    List<int> answersInOfficialOrder,
  ) => FirebaseBackend.instance.submitAcademyExam(answersInOfficialOrder);

  static Future<void> eraseGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_attemptsKey);
  }

  static Future<void> _syncProgress(Set<int> completed) async {
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    try {
      await backend.firestore.collection('academy_progress').doc(backend.uid).set({
        'userId': backend.uid,
        'completedModules': completed.toList()..sort(),
        'lastModule': completed.isEmpty ? null : completed.reduce((a, b) => a > b ? a : b),
        'progressPercentage': (completed.length * 10).round(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
