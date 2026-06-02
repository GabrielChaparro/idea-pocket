import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/app_theme.dart';
import 'tag.dart';

class TagManagerDialog extends StatefulWidget {
  const TagManagerDialog({super.key, required this.api, required this.initialTags});

  final ApiClient api;
  final List<Tag> initialTags;

  @override
  State<TagManagerDialog> createState() => _TagManagerDialogState();
}

class _TagManagerDialogState extends State<TagManagerDialog> {
  final controller = TextEditingController();
  late List<Tag> tags = [...widget.initialTags];
  bool saving = false;
  String? error;

  Future<void> addTag() async {
    if (controller.text.trim().isEmpty || saving) return;

    setState(() => saving = true);
    try {
      final tag = await widget.api.createTag(controller.text);
      controller.clear();
      setState(() {
        error = null;
        tags = [...tags, tag]..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> removeTag(Tag tag) async {
    final confirmed = await confirmDelete(tag);
    if (!confirmed) return;

    try {
      await widget.api.deleteTag(tag.id);
      setState(() {
        error = null;
        tags = tags.where((current) => current.id != tag.id).toList();
      });
    } catch (e) {
      setState(() => error = errorMessage(e));
    }
  }

  Future<bool> confirmDelete(Tag tag) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'BORRAR ETIQUETA',
          style: TextStyle(fontWeight: FontWeight.w900, color: retroRed),
        ),
        content: Text('Esta acción quitará la etiqueta de los registros asociados.\n\n${tag.name}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar'),
          ),
        ],
      ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'ETIQUETAS',
        style: TextStyle(fontWeight: FontWeight.w900, color: retroShell),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Nueva etiqueta',
                errorText: error,
                suffixIcon: IconButton(onPressed: saving ? null : addTag, icon: const Icon(Icons.add), tooltip: 'Crear'),
              ),
              autofocus: true,
              onSubmitted: (_) => addTag(),
            ),
            const SizedBox(height: 12),
            if (tags.isEmpty)
              const Align(alignment: Alignment.centerLeft, child: Text('Sin etiquetas todavía'))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.label_outline),
                      title: Text(tag.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      trailing: IconButton(
                        onPressed: () => removeTag(tag),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Listo')),
      ],
    );
  }
}
