class Task {
  final int id;
  final String title;
  final String? description;
  final String status; // 'PENDING', 'IN_PROGRESS', 'COMPLETED'
  final int userId;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
    };
  }

  // Helper to copy object with changes
  Task copyWith({String? title, String? description, String? status}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      userId: userId,
    );
  }
}