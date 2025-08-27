import 'package:flutter/services.dart';

class HuPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // csak egy példa: ha +36-tal kezdődik, rakjuk szokásos szóközöket
    if (text.startsWith('+36')) {
      final digits = text.replaceAll(RegExp(r'\D'), '');
      // +36 (2) (3) (4) => +36 20 123 4567 mintázat
      String out = '+36';
      var rest = digits.substring(3); // 36 után
      if (rest.isNotEmpty) {
        if (rest.length <= 2) {
          out += ' $rest';
        } else if (rest.length <= 5) {
          out += ' ${rest.substring(0,2)} ${rest.substring(2)}';
        } else if (rest.length <= 8) {
          out += ' ${rest.substring(0,2)} ${rest.substring(2,5)} ${rest.substring(5)}';
        } else {
          out += ' ${rest.substring(0,2)} ${rest.substring(2,5)} ${rest.substring(5,9)}';
        }
      }
      return TextEditingValue(
        text: out,
        selection: TextSelection.collapsed(offset: out.length),
      );
    }

    return newValue;
  }
}
