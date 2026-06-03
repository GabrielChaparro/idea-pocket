import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../core/retro_panel.dart';
import '../tags/tag.dart';
import 'item.dart';

class ItemEditorSheet extends StatefulWidget {
  const ItemEditorSheet({super.key, required this.api, required this.tags, this.item});

  final ApiClient api;
  final List<Tag> tags;
  final Item? item;

  @override
  State<ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<ItemEditorSheet> {
  final title = TextEditingController();
  final content = TextEditingController();
  String type = 'IDEA';
  String priority = 'NORMAL';
  DateTime? dueDate;
  Set<String> selectedTagIds = {};
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      title.text = item.title ?? '';
      content.text = item.content;
      type = item.type;
      priority = item.priority;
      dueDate = item.dueDate;
      selectedTagIds = item.tags.map((tag) => tag.id).toSet();
    }
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final normalizedTitle = title.text.trim();
    final normalizedContent = content.text.trim();
    final fallbackContent = normalizedContent.isEmpty ? normalizedTitle : normalizedContent;

    if (fallbackContent.isEmpty) {
      setState(() => error = 'Escribe al menos un título o contenido.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      final item = widget.item;
      if (item == null) {
        await widget.api.createItem(
          type: type,
          title: normalizedTitle.isEmpty ? null : normalizedTitle,
          content: fallbackContent,
          priority: priority,
          dueDate: type == 'TASK' ? dueDate : null,
          tagIds: selectedTagIds.toList(),
        );
      } else {
        await widget.api.updateItem(
          item: item,
          type: type,
          title: normalizedTitle.isEmpty ? null : normalizedTitle,
          content: fallbackContent,
          priority: priority,
          dueDate: type == 'TASK' ? dueDate : null,
          tagIds: selectedTagIds.toList(),
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = errorMessage(e);
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: RetroPanel(
          shadow: false,
          color: const Color(0xFFECE6C4),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.item == null ? 'NUEVA CAPTURA' : 'EDITAR CAPTURA',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: retroShell),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'IDEA', label: Text('Idea'), icon: Icon(Icons.lightbulb_outline)),
              ButtonSegment(value: 'NOTE', label: Text('Nota'), icon: Icon(Icons.notes)),
              ButtonSegment(value: 'TASK', label: Text('Tarea'), icon: Icon(Icons.check_circle_outline)),
            ],
            selected: {type},
            onSelectionChanged: (value) {
              setState(() {
                type = value.first;
                if (type != 'TASK') dueDate = null;
              });
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'LOW', label: Text('Baja')),
              ButtonSegment(value: 'NORMAL', label: Text('Normal')),
              ButtonSegment(value: 'HIGH', label: Text('Alta')),
            ],
            selected: {priority},
            onSelectionChanged: (value) => setState(() => priority = value.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: title,
            style: retroInputTextStyle,
            decoration: const InputDecoration(labelText: 'Título opcional'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: content,
            style: retroInputTextStyle,
            decoration: InputDecoration(
              labelText: 'Contenido',
              errorText: error,
            ),
            minLines: 3,
            maxLines: 8,
            autofocus: true,
            onChanged: (_) {
              if (error != null) setState(() => error = null);
            },
          ),
          if (type == 'TASK') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDueDate,
              icon: const Icon(Icons.event),
              label: Text(dueDate == null ? 'Añadir fecha límite' : 'Límite: ${formatDateTime(dueDate!)}'),
            ),
            if (dueDate != null)
              TextButton.icon(
                onPressed: () => setState(() => dueDate = null),
                icon: const Icon(Icons.close),
                label: const Text('Quitar fecha límite'),
              ),
          ],
          if (widget.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in widget.tags)
                  FilterChip(
                    label: Text(tag.name),
                    selected: selectedTagIds.contains(tag.id),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTagIds.add(tag.id);
                        } else {
                          selectedTagIds.remove(tag.id);
                        }
                      });
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : save,
            icon: const Icon(Icons.save),
            label: Text(widget.item == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Future<void> pickDueDate() async {
    final now = DateTime.now();
    final initial = dueDate ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    setState(() {
      dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}
