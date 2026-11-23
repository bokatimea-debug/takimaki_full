import 'package:flutter/material.dart';

import '../data/academy_content.dart';
import '../services/academy_progress_store.dart';
import '../theme.dart';
import '../utils/academy_scoring.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});
  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  Set<int> _completed = {};
  Map<String, dynamic>? _latestAttempt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed = await AcademyProgressStore.completedModules();
    final latestAttempt = await AcademyProgressStore.latestAttempt();
    if (mounted) setState(() { _completed = completed; _latestAttempt = latestAttempt; _loading = false; });
  }

  Future<void> _open(AcademyModule module) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AcademyLessonScreen(module: module, completed: _completed.contains(module.id)),
    ));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completed.length / academyModules.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Takarító Akadémia')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
              children: [
                _AcademyHeader(progress: progress, completed: _completed.length),
                const SizedBox(height: 12),
                if (_latestAttempt != null) _SavedExamCard(attempt: _latestAttempt!),
                if (_latestAttempt != null) const SizedBox(height: 12),
                for (final module in academyModules)
                  _ModuleCard(module: module, completed: _completed.contains(module.id), onTap: () => _open(module)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AcademyExamScreen())),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text('Záróvizsga indítása'),
                  style: FilledButton.styleFrom(backgroundColor: takiTeal, foregroundColor: Colors.white),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await AcademyProgressStore.eraseGuestData();
                    await _load();
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A helyi Akadémia-adatok törölve.')));
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Helyi tanulási adatok törlése'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFC62828)),
                ),
              ],
            )),
    );
  }
}

class _SavedExamCard extends StatelessWidget {
  const _SavedExamCard({required this.attempt});
  final Map<String, dynamic> attempt;
  @override
  Widget build(BuildContext context) {
    final percentage = attempt['percentage'] ?? 0;
    final grade = attempt['grade'] ?? 1;
    final passed = attempt['passed'] == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: passed
            ? const [Color(0xFF087B7B), Color(0xFF14AAA5)]
            : const [Color(0xFFFFA51F), Color(0xFFFFC75A)]),
        boxShadow: const [BoxShadow(color: Color(0x24004D4A), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), shape: BoxShape.circle), child: Icon(passed ? Icons.workspace_premium_rounded : Icons.menu_book_rounded, color: Colors.white, size: 30)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Legutóbbi vizsgaeredmény', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('$percentage%  •  $grade-ös', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          Text(passed ? 'Sikeres teljesítés' : 'Bármikor újrapróbálhatod', style: TextStyle(color: Colors.white.withValues(alpha: .92))),
        ])),
      ]),
    );
  }
}

class _AcademyHeader extends StatelessWidget {
  const _AcademyHeader({required this.progress, required this.completed});
  final double progress;
  final int completed;
  @override
  Widget build(BuildContext context) => Card(
    color: takiTealDark,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 30)),
          const SizedBox(width: 12),
          const Expanded(child: Text('Tanulj meg professzionálisan apartmant takarítani!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 16),
        Text('Tanulási előrehaladás  $completed / 10 modul', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: progress, minHeight: 11, color: takiOrange, backgroundColor: Colors.white.withValues(alpha: .25))),
        const SizedBox(height: 5),
        Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.completed, required this.onTap});
  final AcademyModule module;
  final bool completed;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24), onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          _ModuleArt(module: module, compact: true),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${module.id}. ${module.title}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3), Text(module.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: takiMutedText)),
            const SizedBox(height: 6), Text('kb. ${module.duration} perc', style: const TextStyle(color: takiTeal, fontSize: 12, fontWeight: FontWeight.w800)),
          ])),
          Icon(completed ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded, color: completed ? const Color(0xFF3A9B54) : takiTeal, size: 28),
        ]),
      ),
    ),
  );
}

class _ModuleArt extends StatelessWidget {
  const _ModuleArt({required this.module, this.compact = false});
  final AcademyModule module;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final image = 'assets/service_icons/service_${((module.id - 1) % 9).toString().padLeft(2, '0')}.png';
    return Container(
      width: compact ? 58 : double.infinity, height: compact ? 58 : 176,
      decoration: BoxDecoration(
        color: takiMint,
        borderRadius: BorderRadius.circular(compact ? 17 : 26),
      ),
      clipBehavior: Clip.antiAlias,
      child: compact
          ? Icon(module.icon, color: takiTealDark, size: 31)
          : Stack(fit: StackFit.expand, children: [
              // A lesson always opens with a real decorative illustration,
              // not merely a faded background icon.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, takiMint.withValues(alpha: .72)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .92),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Color(0x24004D4A), blurRadius: 10, offset: Offset(0, 3))],
                  ),
                  child: Icon(module.icon, color: takiTealDark, size: 30),
                ),
              ),
            ]),
    );
  }
}

class AcademyLessonScreen extends StatefulWidget {
  const AcademyLessonScreen({super.key, required this.module, required this.completed});
  final AcademyModule module;
  final bool completed;
  @override
  State<AcademyLessonScreen> createState() => _AcademyLessonScreenState();
}

class _AcademyLessonScreenState extends State<AcademyLessonScreen> {
  bool _done = false;
  @override
  void initState() { super.initState(); _done = widget.completed; }
  Future<void> _finish() async {
    await AcademyProgressStore.completeModule(widget.module.id);
    if (!mounted) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecke teljesítve.')));
  }

  Future<void> _openPractice() async {
    final completedPractice = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => AcademyPracticeScreen(module: widget.module),
    ));
    if (completedPractice != true || !mounted) return;
    await _finish();
    if (!mounted) return;
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return Scaffold(
      appBar: AppBar(title: Text('${m.id}. modul: ${m.title}')),
      backgroundColor: const Color(0xFFF1FBFA),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 152), children: [
        _ModuleArt(module: m), const SizedBox(height: 12),
        Text(m.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6), Text(m.introduction, style: const TextStyle(fontSize: 16, height: 1.45)),
        if (m.tools.isNotEmpty) _BulletSection(title: 'Szükséges eszközök', icon: Icons.inventory_2_outlined, items: m.tools),
        _BulletSection(title: 'Lépések', icon: Icons.format_list_numbered_rounded, items: m.steps, numbered: true),
        _BulletSection(title: 'Tipikus hibák', icon: Icons.error_outline_rounded, items: m.mistakes, color: const Color(0xFFC86B55)),
        _BulletSection(title: 'Biztonság', icon: Icons.health_and_safety_outlined, items: m.safety, color: takiOrange),
        _BulletSection(title: 'Rövid ellenőrzőlista', icon: Icons.checklist_rounded, items: m.checklist, color: const Color(0xFF3A9B54)),
      ]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _openPractice,
              icon: Icon(_done ? Icons.check_circle_rounded : Icons.quiz_outlined),
              label: Text(_done ? 'Lecke teljesítve' : 'Ellenőrző kérdések (3)'),
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.icon, required this.items, this.color = takiTeal, this.numbered = false});
  final String title; final IconData icon; final List<String> items; final Color color; final bool numbered;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 10),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge)]),
      const SizedBox(height: 7),
      for (var i = 0; i < items.length; i++) Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(numbered ? '${i + 1}. ' : '• ', style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        Expanded(child: Text(items[i], style: const TextStyle(fontSize: 15, height: 1.28))),
      ])),
    ])),
  );
}

class AcademyPracticeScreen extends StatefulWidget {
  const AcademyPracticeScreen({super.key, required this.module});
  final AcademyModule module;
  @override
  State<AcademyPracticeScreen> createState() => _AcademyPracticeScreenState();
}

class _AcademyPracticeScreenState extends State<AcademyPracticeScreen> {
  int _index = 0;
  int? _selected;
  int _correct = 0;
  bool _retry = false;
  AcademyQuestion get _question => widget.module.questions[_index];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ellenőrző kérdések')),
    backgroundColor: const Color(0xFFF1FBFA),
    body: SafeArea(top: false, child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), children: [
      _QuestionProgressBanner(kicker: 'GYAKORLÓ KÉRDÉSEK', current: _index + 1, total: widget.module.questions.length, accent: takiTeal, icon: Icons.psychology_alt_rounded),
      const SizedBox(height: 18),
      _QuestionCard(question: _question.question, accent: takiTeal),
      const SizedBox(height: 14),
      for (var i = 0; i < _question.options.length; i++) _AnswerTile(index: i, label: _question.options[i], selected: _selected, correct: _question.correctIndex, reveal: _selected != null, accent: takiTeal, onTap: () {
        if (_selected != null) return;
        setState(() {
          _selected = i;
          if (i == _question.correctIndex) _correct++;
        });
      }),
      if (_selected != null) _AnswerFeedback(correct: _selected == _question.correctIndex, text: _question.explanation),
      if (_retry) const _AnswerFeedback(correct: false, text: 'Most 3/3 helyes válasz kell a lecke teljesítéséhez. Próbáld meg újra.'),
    ])),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: SizedBox(height: 52, child: FilledButton(
          onPressed: _retry ? () => setState(() { _index = 0; _selected = null; _correct = 0; _retry = false; }) : _selected == null ? null : () {
            if (_index + 1 == widget.module.questions.length) {
              if (_correct == widget.module.questions.length) {
                Navigator.pop(context, true);
              } else {
                setState(() => _retry = true);
              }
            } else {
              setState(() { _index++; _selected = null; });
            }
          },
          child: Text(_retry ? 'Kérdések újrakezdése' : _index + 1 == widget.module.questions.length ? 'Eredmény' : 'Következő kérdés'),
        )),
      ),
    ),
  );
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.index, required this.label, required this.selected, required this.correct, required this.reveal, required this.accent, required this.onTap});
  final int index; final String label; final int? selected; final int correct; final bool reveal; final Color accent; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isCorrect = index == correct;
    final chosen = selected == index;
    final color = reveal && isCorrect ? const Color(0xFF3A9B54) : reveal && chosen ? const Color(0xFFC86B55) : accent;
    final background = reveal && isCorrect ? const Color(0xFFE2F4E6) : reveal && chosen ? const Color(0xFFFFE8E4) : chosen ? accent.withValues(alpha: .12) : Colors.white;
    return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20), border: Border.all(color: chosen || (reveal && isCorrect) ? color : const Color(0xFFE2EFED), width: chosen || (reveal && isCorrect) ? 2 : 1), boxShadow: const [BoxShadow(color: Color(0x0D004D4A), blurRadius: 7, offset: Offset(0, 3))]), child: InkWell(onTap: reveal ? null : onTap, borderRadius: BorderRadius.circular(19), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 31, height: 31, alignment: Alignment.center, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Text(String.fromCharCode(65 + index), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w600))),
      if (reveal && (isCorrect || chosen)) Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color),
    ]))));
  }
}

class _QuestionProgressBanner extends StatelessWidget {
  const _QuestionProgressBanner({required this.kicker, required this.current, required this.total, required this.accent, required this.icon});
  final String kicker; final int current; final int total; final Color accent; final IconData icon;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x26004D4A), blurRadius: 12, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: Icon(icon, color: Colors.white)), const SizedBox(width: 10), Expanded(child: Text(kicker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: .5))), Text('$current / $total', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 14), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: current / total, minHeight: 8, color: Colors.white, backgroundColor: Colors.white.withValues(alpha: .25))),
  ]));
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.accent});
  final String question; final Color accent;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: accent.withValues(alpha: .18)), boxShadow: const [BoxShadow(color: Color(0x12004D4A), blurRadius: 12, offset: Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('MIT GONDOLSZ?', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 9), Text(question, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.18, fontWeight: FontWeight.w900)),
  ]));
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.correct, required this.text});
  final bool correct; final String text;
  @override
  Widget build(BuildContext context) { final color = correct ? const Color(0xFF3A9B54) : const Color(0xFFC86B55); return Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: .3))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(correct ? Icons.auto_awesome_rounded : Icons.lightbulb_outline_rounded, color: color), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(height: 1.35, fontWeight: FontWeight.w600)))])); }
}

class AcademyExamScreen extends StatefulWidget {
  const AcademyExamScreen({super.key});
  @override
  State<AcademyExamScreen> createState() => _AcademyExamScreenState();
}

class _AcademyExamScreenState extends State<AcademyExamScreen> {
  late final List<AcademyQuestion> _questions;
  late final List<int?> _answers;
  int _index = 0;
  @override
  void initState() { super.initState(); _questions = List.of(academyExam)..shuffle(); _answers = List<int?>.filled(_questions.length, null); }
  Future<void> _finish() async {
    if (_answers.any((a) => a == null)) return;
    var correct = 0;
    for (var i = 0; i < _questions.length; i++) if (_answers[i] == _questions[i].correctIndex) correct++;
    final score = AcademyScore(correct, _questions.length);
    await AcademyProgressStore.saveAttempt(correctCount: correct, percentage: score.percentage, grade: score.grade, passed: score.passed, answers: _answers.cast<int>());
    // The on-device score gives guest learners immediate feedback. When a
    // signed-in account and Cloud Function are available, the same attempt is
    // also evaluated in the canonical original question order by the server.
    final officialAnswers = academyExam
        .map((question) => _answers[_questions.indexOf(question)]!)
        .toList();
    await AcademyProgressStore.submitForOfficialVerification(officialAnswers);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AcademyResultScreen(correct: correct, percentage: score.percentage, grade: score.grade, questions: _questions, answers: _answers.cast<int>())));
  }
  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Záróvizsga')),
      backgroundColor: const Color(0xFFF1FBFA),
      body: SafeArea(top: false, child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), children: [
        const _ExamNotice(),
        const SizedBox(height: 12),
        _QuestionProgressBanner(kicker: 'ZÁRÓVIZSGA', current: _index + 1, total: 20, accent: takiTealDark, icon: Icons.workspace_premium_rounded),
        const SizedBox(height: 18), _QuestionCard(question: question.question, accent: takiOrange), const SizedBox(height: 14),
        for (var i = 0; i < question.options.length; i++) _AnswerTile(index: i, label: question.options[i], selected: _answers[_index], correct: question.correctIndex, reveal: false, accent: takiOrange, onTap: () => setState(() => _answers[_index] = i)),
      ])),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: _index == 0 ? null : () => setState(() => _index--), child: const Text('Vissza'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: SizedBox(height: 52, child: FilledButton(onPressed: _answers[_index] == null ? null : () { if (_index == 19) _finish(); else setState(() => _index++); }, child: Text(_index == 19 ? 'Eredmény' : 'Következő')))),
          ]),
        ),
      ),
    );
  }
}

class _ExamNotice extends StatelessWidget {
  const _ExamNotice();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: takiOrange.withValues(alpha: .17), borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.visibility_off_rounded, color: takiTealDark, size: 20), SizedBox(width: 8), Expanded(child: Text('A helyes megoldásokat az eredmény után mutatjuk.', style: TextStyle(fontWeight: FontWeight.w700, color: takiTealDark)))]));
}

class AcademyResultScreen extends StatelessWidget {
  const AcademyResultScreen({super.key, required this.correct, required this.percentage, required this.grade, required this.questions, required this.answers});
  final int correct; final int percentage; final int grade; final List<AcademyQuestion> questions; final List<int> answers;
  @override
  Widget build(BuildContext context) {
    final passed = grade >= 4;
    final label = ['Elégtelen', 'Elégséges', 'Közepes', 'Jó', 'Jeles'][grade - 1];
    return Scaffold(
      appBar: AppBar(title: const Text('Vizsgaeredmény')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Card(color: passed ? const Color(0xFFE2F4E6) : const Color(0xFFFFF0E8), child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          Icon(passed ? Icons.workspace_premium_rounded : Icons.menu_book_rounded, color: passed ? const Color(0xFF3A9B54) : takiOrange, size: 58),
          const SizedBox(height: 10), Text('$percentage%', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: takiTealDark)),
          Text('$grade – ${label.toUpperCase()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8), Text('$correct / 20 helyes válasz', style: const TextStyle(color: takiMutedText)),
          const SizedBox(height: 12), Text(passed ? 'Gratulálunk! Sikeresen teljesítetted a Takimaki Takarító Akadémia vizsgáját. Most ingyenesen regisztrálhatsz takarítóként és munkát kereshetsz.' : 'Érdemes még gyakorolnod! Ismételd át az alábbi hibás témákat, majd próbáld meg újra.', textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
        ]))),
        const SizedBox(height: 12),
        if (passed) FilledButton.icon(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/role_select', (route) => false),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Regisztrálj apartmantakarítónak'),
          style: FilledButton.styleFrom(backgroundColor: takiTeal, foregroundColor: Colors.white),
        ),
        if (!passed) FilledButton.icon(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/academy', (route) => false),
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('Tananyag ismétlése'),
          style: FilledButton.styleFrom(backgroundColor: takiOrange, foregroundColor: takiTealDark),
        ),
        if (!passed) OutlinedButton.icon(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AcademyExamScreen())),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Vizsga újrakezdése'),
          style: OutlinedButton.styleFrom(foregroundColor: takiOrange, side: const BorderSide(color: takiOrange)),
        ),
        if (correct < 20) FilledButton.tonalIcon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AcademyErrorReviewScreen(questions: questions, answers: answers))),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Hibás válaszok és megoldások'),
          style: FilledButton.styleFrom(backgroundColor: takiMint, foregroundColor: takiTealDark),
        ),
      ]),
    );
  }
}

class AcademyErrorReviewScreen extends StatelessWidget {
  const AcademyErrorReviewScreen({super.key, required this.questions, required this.answers});
  final List<AcademyQuestion> questions;
  final List<int> answers;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hibás válaszok és megoldások')),
    backgroundColor: const Color(0xFFF1FBFA),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          for (var i = 0; i < questions.length; i++)
            if (answers[i] != questions[i].correctIndex)
              Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(questions[i].question, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Helyes: ${questions[i].options[questions[i].correctIndex]}', style: const TextStyle(color: Color(0xFF27763B), fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(questions[i].explanation),
              ]))),
        ],
      ),
    ),
  );
}
