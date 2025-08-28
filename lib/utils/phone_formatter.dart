import 'package:flutter/services.dart';

class HuPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (!raw.startsWith('+36')) {
      const fixed = '+36 ';
      return TextEditingValue(text: fixed,
          selection: const TextSelection.collapsed(offset: fixed.length));
    }
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (!digits.startsWith('36')) {
      const fixed = '+36 ';
      return TextEditingValue(text: fixed,
          selection: const TextSelection.collapsed(offset: fixed.length));
    }
    String out = '+36';
    String rest = digits.substring(2);
    if (rest.isEmpty) out += ' ';
    else if (rest.length <= 2) out += ' ${rest.substring(0)}';
    else if (rest.length <= 5) out += ' ${rest.substring(0,2)} ${rest.substring(2)}';
    else if (rest.length <= 9) out += ' ${rest.substring(0,2)} ${rest.substring(2,5)} ${rest.substring(5)}';
    else out += ' ${rest.substring(0,2)} ${rest.substring(2,5)} ${rest.substring(5,9)}';
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
