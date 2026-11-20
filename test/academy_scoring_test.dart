import 'package:flutter_test/flutter_test.dart';
import 'package:takimaki_full/utils/academy_scoring.dart';

void main() {
  group('AcademyScore', () {
    test('required grade boundaries are exact', () {
      expect(AcademyScore(0, 20).percentage, 0);
      expect(AcademyScore(0, 20).grade, 1);
      expect(AcademyScore(8, 20).grade, 2);
      expect(AcademyScore(12, 20).grade, 3);
      expect(AcademyScore(16, 20).grade, 4);
      expect(AcademyScore(18, 20).grade, 5);
      expect(AcademyScore(20, 20).grade, 5);
    });
    test('only grade four and five pass', () {
      expect(AcademyScore(15, 20).passed, isFalse);
      expect(AcademyScore(16, 20).passed, isTrue);
    });
  });
}
