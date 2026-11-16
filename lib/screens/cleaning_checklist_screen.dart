import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cleaning_checklist.dart';
import '../widgets/taki_app_bar.dart';

class CleaningChecklistScreen extends StatefulWidget {
  const CleaningChecklistScreen({
    super.key,
    required this.tasks,
    this.template = false,
    this.cleaner = false,
  });

  final List<Map<String, dynamic>> tasks;
  final bool template;
  final bool cleaner;

  @override
  State<CleaningChecklistScreen> createState() => _ChecklistState();
}

class _ChecklistState extends State<CleaningChecklistScreen> {
  late final tasks = CleaningChecklist.tasks(widget.tasks);
  bool busy = false;

  Future<void> photo(Map<String, dynamic> task, {required bool reference}) async {
    setState(() => busy = true);
    try {
      final selected = await ImagePicker().pickImage(
        source: reference ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1280, maxHeight: 1280, imageQuality: 65,
        requestFullMetadata: false,
      );
      if (selected == null || !mounted) return;
      final bytes = await selected.readAsBytes();
      if (bytes.isEmpty || bytes.length > 500 * 1024) {
        throw StateError('A kép nem menthető. Próbálj kisebb képet.');
      }
      if (!mounted) return;
      setState(() {
        task[reference ? 'reference' : 'photo'] = base64Encode(bytes);
        if (!reference && task['photoRequired'] == true) task['done'] = true;
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A kép nem menthető. Próbálj kisebb képet.')),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit(String room, [Map<String, dynamic>? task]) async {
    var value = task?['label'] as String? ?? '';
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Takarítási feladat'),
        content: TextFormField(initialValue: value, autofocus: true,
          maxLength: 140, onChanged: (text) => value = text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
          FilledButton(onPressed: () => Navigator.pop(context, value.trim()),
            child: const Text('Mentés')),
        ],
      ),
    );
    if (!mounted || label == null || label.isEmpty) return;
    setState(() {
      if (task == null) {
        tasks.add({'room': room, 'label': label});
      } else {
        task['label'] = label;
      }
    });
  }

  Widget image(String label, String data) => Column(
    children: [
      Text(label),
      InkWell(
        onTap: () => showDialog<void>(context: context, builder: (_) =>
          Dialog(child: InteractiveViewer(child: Image.memory(base64Decode(data))))),
        child: Image.memory(base64Decode(data), height: 110,
          cacheWidth: 320, semanticLabel: label),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Takarítási checklist')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('${tasks.where((task) => task['done'] == true).length}/${tasks.length} kész'),
      for (final room in rooms.keys) ...[
        ExpansionTile(
          title: Text(room),
          children: [
            for (final task in tasks.where((task) => task['room'] == room))
              Card(child: Column(children: [
                if (widget.template)
                  ListTile(
                    title: Text('${task['label']}'),
                    onTap: busy ? null : () => edit(room, task),
                    trailing: IconButton(
                      tooltip: 'Feladat törlése',
                      onPressed: busy ? null : () => setState(() => tasks.remove(task)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  )
                else
                  CheckboxListTile(
                    title: Text('${task['label']}'),
                    value: task['done'] == true,
                    onChanged: !widget.cleaner || busy ||
                        (task['photoRequired'] == true && task['photo'] == null)
                      ? null : (value) => setState(() => task['done'] = value == true),
                  ),
                if (widget.template)
                  SwitchListTile(
                    title: const Text('Kötelező fotó'),
                    value: task['photoRequired'] == true,
                    onChanged: busy ? null : (value) =>
                        setState(() => task['photoRequired'] = value),
                  ),
                if (task['reference'] is String)
                  image('Referenciafotó', task['reference'] as String),
                if (task['photo'] is String)
                  image('Elkészült munka', task['photo'] as String),
                if (widget.template || (widget.cleaner && task['photoRequired'] == true))
                  TextButton.icon(
                    onPressed: busy ? null : () => photo(task, reference: widget.template),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(widget.template ? 'Referenciafotó' : 'Ellenőrzőfotó készítése'),
                  ),
              ])),
            if (widget.template)
              TextButton(onPressed: busy ? null : () => edit(room),
                child: const Text('Feladat hozzáadása')),
          ],
        ),
      ],
      if (widget.template || widget.cleaner)
        FilledButton(
          onPressed: busy || tasks.isEmpty ? null : () => Navigator.pop(context, tasks),
          child: const Text('Mentés'),
        ),
    ])),
  );
}
