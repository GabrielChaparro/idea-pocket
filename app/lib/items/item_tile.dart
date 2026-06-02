import 'package:flutter/material.dart';

import '../core/app_theme.dart';
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
    final overdue = item.dueDate != null && item.dueDate!.isBefore(DateTime.now()) && !completed;
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: retroInk, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Card(
        child: ListTile(
          minVerticalPadding: 12,
          leading: IconButton(
            onPressed: onComplete,
            icon: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked),
            tooltip: completed ? 'Reabrir' : 'Completar',
          ),
          title: Text(
            item.title?.isNotEmpty == true ? item.title! : item.content,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              decoration: completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.type} // ${item.priority}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: retroShell),
                ),
                if (item.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'LIMITE // ${formatDateTime(item.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: overdue ? retroRed : retroInk,
                    ),
                  ),
                ],
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final tag in item.tags)
                        Chip(
                          label: Text(tag.name),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          trailing: Wrap(
            spacing: 4,
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Editar'),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar'),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} ${two(value.hour)}:${two(value.minute)}';
  }
}
