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
    final overdue =
        item.dueDate != null &&
        item.dueDate!.isBefore(DateTime.now()) &&
        !completed;
    final accent = switch (item.type) {
      'TASK' => retroAmber,
      'NOTE' => arcadeCyan,
      _ => arcadePink,
    };
    final icon = switch (item.type) {
      'TASK' => Icons.check_circle_outline,
      'NOTE' => Icons.notes,
      _ => Icons.lightbulb_outline,
    };
    return Container(
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFE2E0BE) : retroPanel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: retroInk, width: 2),
        boxShadow: [
          const BoxShadow(color: retroInk, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 9, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: onComplete,
                        icon: Icon(
                          completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                        tooltip: completed ? 'Reabrir' : 'Completar',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title?.isNotEmpty == true
                                ? item.title!
                                : item.content,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _Badge(
                                icon: icon,
                                text: item.type,
                                color: accent,
                              ),
                              _Badge(
                                icon: Icons.flash_on,
                                text: item.priority,
                                color: retroMint,
                              ),
                            ],
                          ),
                          if (item.dueDate != null) ...[
                            const SizedBox(height: 6),
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
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Eliminar',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: retroInk, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: retroInk),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: retroInk,
            ),
          ),
        ],
      ),
    );
  }
}
