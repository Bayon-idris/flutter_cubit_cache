import '../../data/models/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {} // État initial (vide)

class TaskLoading extends TaskState {} // Chargement

class TaskLoaded extends TaskState {
  // Données chargées avec succès
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  // Erreur lors du chargement
  final String message;

  TaskError(this.message);
}

class TaskEmpty extends TaskState {} // État initial (vide)
