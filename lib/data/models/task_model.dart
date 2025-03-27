import 'package:hive/hive.dart';

part 'task_model.g.dart';

// 📌 Indique que cette classe est un modèle Hive avec un type ID unique
@HiveType(typeId: 0)
class Task {
  // 📌 Chaque champ doit avoir un index unique pour Hive
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String createdAt;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
    };
  }
}
