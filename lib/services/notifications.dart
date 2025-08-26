// lib/services/notifications.dart
import 'package:flutter/material.dart';

SnackBar _sb(String msg, {Color? color}) => SnackBar(
  content: Text(msg),
  duration: const Duration(seconds: 2),
  behavior: SnackBarBehavior.floating,
  backgroundColor: color,
);

class Notifier {
  static void info(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(_sb(msg));
  }

  static void success(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(_sb(msg, color: Colors.green));
  }

  static void warn(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(_sb(msg, color: Colors.orange));
  }

  static void error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(_sb(msg, color: Colors.red));
  }
}

