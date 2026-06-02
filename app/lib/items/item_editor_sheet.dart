import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
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
      selectedTagIds = item.tags.map((tag) => tag.id).toSet();
    }
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
          tagIds: selectedTagIds.toList(),
        );
      } else {
        await widget.api.updateItem(
          item: item,
          type: type,
          title: normalizedTitle.isEmpty ? null : normalizedTitle,
          content: fallbackContent,
          priority: priority,
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'IDEA', label: Text('Idea'), icon: Icon(Icons.lightbulb_outline)),
              ButtonSegment(value: 'NOTE', label: Text('Nota'), icon: Icon(Icons.notes)),
              ButtonSegment(value: 'TASK', label: Text('Tarea'), icon: Icon(Icons.check_circle_outline)),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
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
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Título opcional')),
          const SizedBox(height: 12),
          TextField(
            controller: content,
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
    );
  }
}
