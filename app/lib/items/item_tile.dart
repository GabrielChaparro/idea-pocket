import 'package:flutter/material.dart';

import 'item.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final completed = item.status == 'COMPLETED';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: IconButton(
          onPressed: onComplete,
          icon: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked),
          tooltip: completed ? 'Reabrir' : 'Completar',
        ),
        title: Text(item.title?.isNotEmpty == true ? item.title! : item.content),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.type} · ${item.priority}'),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in item.tags) Chip(label: Text(tag.name), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Editar'),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar'),
          ],
        ),
      ),
    );
  }
}

