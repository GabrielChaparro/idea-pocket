import '../tags/tag.dart';

class Item {
  Item({
    required this.id,
    required this.type,
    required this.content,
    required this.status,
    required this.priority,
    required this.tags,
    this.title,
    this.dueDate,
  });

  final String id;
  final String type;
  final String? title;
  final String content;
  final String status;
  final String priority;
  final List<Tag> tags;
  final DateTime? dueDate;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String).toLocal(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
          .toList(),
    );
  }
}
