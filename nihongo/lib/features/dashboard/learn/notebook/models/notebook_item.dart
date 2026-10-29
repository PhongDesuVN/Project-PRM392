class NotebookItem {
  final int id;
  final int userId;
  final String title;
  final String description;
  final int wordCount;
  final String createdAt;

  const NotebookItem({
    required this.id,
    this.userId = 1,
    required this.title,
    this.description = '',
    this.wordCount = 0,
    required this.createdAt,
  });

  factory NotebookItem.fromJson(Map<String, dynamic> json) {
    return NotebookItem(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 1,
      title: json['title'] as String? ?? 'Sổ tay',
      description: json['description'] as String? ?? '',
      wordCount: json['wordCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'wordCount': wordCount,
    'createdAt': createdAt,
  };

  NotebookItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    int? wordCount,
    String? createdAt,
  }) {
    return NotebookItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

