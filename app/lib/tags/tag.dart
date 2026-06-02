class Tag {
  Tag({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }
}

