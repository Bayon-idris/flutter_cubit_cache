import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_cache/presentation/cubits/tasks_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit({required this.repository}) : super(TaskInitial()) {
    fetchTasks();
  }

  void fetchTasks() async {
    // 🔹 1. Charger les tâches en cache immédiatement
    final cachedTasks = repository.localSource.getTasks();
    if (cachedTasks.isNotEmpty) {
      emit(TaskLoaded(cachedTasks));
    }

    // 🔹 2. Aller chercher les nouvelles tâches en ligne (en arrière-plan) uniquement si elles ont changé
    try {
      final freshTasks = await repository.fetchAll();
      if (_tasksHaveChanged(cachedTasks, freshTasks)) {
        repository.localSource.saveTasks(freshTasks); // Mettre à jour le cache
        emit(TaskLoaded(freshTasks)); // Mise à jour de l'UI
      }
    } catch (e) {
      if (cachedTasks.isEmpty) {
        emit(TaskError("Échec du chargement des tâches"));
      }
    }
  }

  // Vérifier si les tâches ont changé
  bool _tasksHaveChanged(List<Task> cachedTasks, List<Task> freshTasks) {
    return cachedTasks.length != freshTasks.length ||
        !cachedTasks.every((cachedTask) =>
            freshTasks.any((freshTask) => freshTask.id == cachedTask.id && freshTask.name == cachedTask.name && freshTask.description == cachedTask.description));
  }

  // Ajouter une tâche
  Future<void> addTask(Task newTask) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = List<Task>.from(currentState.tasks)..add(newTask);
      emit(TaskLoaded(updatedTasks)); // ✅ Met à jour la liste immédiatement

      try {
        final addedTask = await repository.add(newTask);
        final finalTasks = List<Task>.from(updatedTasks)
          ..remove(newTask)
          ..add(addedTask);
        repository.localSource.saveTasks(finalTasks); // ✅ Met à jour le cache
        emit(TaskLoaded(finalTasks)); // ✅ Mise à jour avec la vraie réponse de l’API
      } catch (e) {
        emit(TaskLoaded(currentState.tasks)); // ❌ Annule l'ajout en cas d'erreur
      }
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    try {
      await repository.update(task);
      fetchTasks(); // Rafraîchir
    } catch (e) {
      emit(TaskError('Erreur lors de la mise à jour de la tâche'));
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks.where((task) => task.id != taskId).toList();
      emit(TaskLoaded(updatedTasks)); // ✅ Supprime immédiatement la tâche de la liste

      try {
        await repository.delete(taskId);
        repository.localSource.saveTasks(updatedTasks); // ✅ Met à jour le cache
      } catch (e) {
        emit(TaskLoaded(currentState.tasks)); // ❌ Si erreur, on remet l’ancienne liste
      }
    }
  }
}
