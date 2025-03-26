import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_cache/presentation/cubits/tasks_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit({required this.repository}) : super(TaskInitial()) {
    fetchTasks();
  }

  // Récupérer les tâches (affiche le cache d’abord)
  Future<void> fetchTasks() async {
    try {
      emit(TaskLoading()); // Loader uniquement si c'est le premier appel
      final tasks = await repository.fetchAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Erreur lors du chargement des tâches'));
    }
  }

  // Ajouter une tâche
  Future<void> addTask(Task newTask) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = List<Task>.from(currentState.tasks)..add(newTask);
      emit(TaskLoaded(updatedTasks)); // ✅ Met à jour la liste immédiatement

      try {
        final addedTask = await repository.add(newTask);
        final finalTasks = List<Task>.from(updatedTasks)..remove(newTask)..add(addedTask);
        emit(TaskLoaded(finalTasks)); // ✅ Met à jour avec la vraie réponse de l’API
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
      } catch (e) {
        emit(TaskLoaded(currentState.tasks)); // ❌ Si erreur, on remet l’ancienne liste
      }
    }
  }

}
