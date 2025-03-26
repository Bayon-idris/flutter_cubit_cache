class Task {
  final String id;
  final String name;
  final String description;
  final String createdAt;
  final bool completed;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'completed': completed,
    };
  }
}