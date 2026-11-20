class AcademyScore {
  const AcademyScore(this.correctCount, this.total);
  final int correctCount;
  final int total;

  int get percentage => (correctCount / total * 100).round();
  int get grade => percentage >= 90 ? 5 : percentage >= 80 ? 4 : percentage >= 60 ? 3 : percentage >= 40 ? 2 : 1;
  bool get passed => grade >= 4;
}
