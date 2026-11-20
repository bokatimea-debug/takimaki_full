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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed = await AcademyProgressStore.completedModules();
    if (mounted) setState(() { _completed = completed; _loading = false; });
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
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                _AcademyHeader(progress: progress, completed: _completed.length),
                const SizedBox(height: 12),
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
                ),
              ],
            ),
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
      width: compact ? 58 : double.infinity, height: compact ? 58 : 138,
      decoration: BoxDecoration(color: takiMint, borderRadius: BorderRadius.circular(compact ? 17 : 24)),
      clipBehavior: Clip.antiAlias,
      child: compact
          ? Icon(module.icon, color: takiTealDark, size: 31)
          : Stack(fit: StackFit.expand, children: [
              Opacity(opacity: .26, child: Image.asset(image, fit: BoxFit.cover)),
              Center(child: Icon(module.icon, color: takiTealDark, size: 62)),
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
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return Scaffold(
      appBar: AppBar(title: Text('${m.id}. modul: ${m.title}')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), children: [
        _ModuleArt(module: m), const SizedBox(height: 12),
        Text(m.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6), Text(m.introduction, style: const TextStyle(fontSize: 16, height: 1.45)),
        if (m.tools.isNotEmpty) _BulletSection(title: 'Szükséges eszközök', icon: Icons.inventory_2_outlined, items: m.tools),
        _BulletSection(title: 'Lépések', icon: Icons.format_list_numbered_rounded, items: m.steps, numbered: true),
        _BulletSection(title: 'Tipikus hibák', icon: Icons.error_outline_rounded, items: m.mistakes, color: const Color(0xFFC86B55)),
        _BulletSection(title: 'Biztonság', icon: Icons.health_and_safety_outlined, items: m.safety, color: takiOrange),
        _BulletSection(title: 'Rövid ellenőrzőlista', icon: Icons.checklist_rounded, items: m.checklist, color: const Color(0xFF3A9B54)),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _done ? null : _finish, icon: Icon(_done ? Icons.check : Icons.task_alt_rounded), label: Text(_done ? 'Lecke teljesítve' : 'Lecke befejezése')),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AcademyPracticeScreen(module: m))),
          icon: const Icon(Icons.quiz_outlined), label: const Text('Ellenőrző kérdések (3)'),
        ),
      ]),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.icon, required this.items, this.color = takiTeal, this.numbered = false});
  final String title; final IconData icon; final List<String> items; final Color color; final bool numbered;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 14),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge)]),
      const SizedBox(height: 10),
      for (var i = 0; i < items.length; i++) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(numbered ? '${i + 1}. ' : '• ', style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        Expanded(child: Text(items[i], style: const TextStyle(height: 1.36))),
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
  int _index = 0; int? _selected;
  AcademyQuestion get _question => widget.module.questions[_index];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ellenőrző kérdések')),
    body: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${_index + 1} / ${widget.module.questions.length} kérdés', style: const TextStyle(fontWeight: FontWeight.w800, color: takiTeal)),
      const SizedBox(height: 8), LinearProgressIndicator(value: (_index + 1) / widget.module.questions.length, color: takiTeal),
      const SizedBox(height: 26), Text(_question.question, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 18),
      for (var i = 0; i < _question.options.length; i++) _AnswerTile(index: i, label: _question.options[i], selected: _selected, correct: _question.correctIndex, reveal: _selected != null, onTap: () => setState(() => _selected ??= i)),
      if (_selected != null) Card(color: _selected == _question.correctIndex ? const Color(0xFFE2F4E6) : const Color(0xFFFFE8E4), child: Padding(padding: const EdgeInsets.all(14), child: Text(_question.explanation))),
      const Spacer(),
      FilledButton(onPressed: _selected == null ? null : () { if (_index + 1 == widget.module.questions.length) Navigator.pop(context); else setState(() { _index++; _selected = null; }); }, child: Text(_index + 1 == widget.module.questions.length ? 'Vissza a leckéhez' : 'Következő kérdés')),
    ])),
  );
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.index, required this.label, required this.selected, required this.correct, required this.reveal, required this.onTap});
  final int index; final String label; final int? selected; final int correct; final bool reveal; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isCorrect = index == correct;
    final chosen = selected == index;
    final color = reveal && isCorrect ? const Color(0xFF3A9B54) : reveal && chosen ? const Color(0xFFC86B55) : takiTeal;
    return Card(child: InkWell(onTap: reveal ? null : onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Icon(reveal && isCorrect ? Icons.check_circle : chosen ? Icons.radio_button_checked : Icons.radio_button_off, color: color), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontSize: 16, height: 1.25))),
    ]))));
  }
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
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AcademyResultScreen(correct: correct, percentage: score.percentage, grade: score.grade, questions: _questions, answers: _answers.cast<int>())));
  }
  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Záróvizsga')),
      body: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${_index + 1} / 20 kérdés', style: const TextStyle(fontWeight: FontWeight.w800, color: takiTeal)),
        const SizedBox(height: 8), LinearProgressIndicator(value: (_index + 1) / 20, minHeight: 7, color: takiTeal),
        const SizedBox(height: 28), Text(question.question, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 18),
        for (var i = 0; i < question.options.length; i++) _ExamAnswer(index: i, label: question.options[i], selected: _answers[_index] == i, onTap: () => setState(() => _answers[_index] = i)),
        const Spacer(),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _index == 0 ? null : () => setState(() => _index--), child: const Text('Vissza'))), const SizedBox(width: 12),
          Expanded(child: FilledButton(onPressed: _answers[_index] == null ? null : () { if (_index == 19) _finish(); else setState(() => _index++); }, child: Text(_index == 19 ? 'Eredmény' : 'Következő'))),
        ]),
      ])),
    );
  }
}

class _ExamAnswer extends StatelessWidget {
  const _ExamAnswer({required this.index, required this.label, required this.selected, required this.onTap});
  final int index; final String label; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? takiTeal : takiMutedText), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
  ]))));
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
        if (passed) FilledButton.icon(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/role_select', (route) => false), icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Ingyenes regisztráció és munkakeresés')),
        if (!passed) FilledButton.icon(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/academy', (route) => false), icon: const Icon(Icons.menu_book_rounded), label: const Text('Tananyag ismétlése')),
        OutlinedButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AcademyExamScreen())), icon: const Icon(Icons.refresh_rounded), label: const Text('Vizsga újra')),
        const SizedBox(height: 8), Text('Hibás válaszok és megoldások', style: Theme.of(context).textTheme.titleLarge),
        for (var i = 0; i < questions.length; i++) if (answers[i] != questions[i].correctIndex) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(questions[i].question, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6),
          Text('Helyes: ${questions[i].options[questions[i].correctIndex]}', style: const TextStyle(color: Color(0xFF27763B), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4), Text(questions[i].explanation),
        ]))),
      ]),
    );
  }
}
