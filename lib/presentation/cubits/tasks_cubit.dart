import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_cache/core/utils/constants.dart';
import 'package:flutter_cubit_cache/presentation/cubits/tasks_state.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit({required this.repository}) : super(TaskInitial()) {
    fetchTasks();
  }

  void fetchTasks() async {
    final cachedTasks = repository.localSource.getTasks();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final lastFetchTime = await repository.localSource.getLastFetchTime();

    // 🔹 1. Toujours afficher les tâches en cache immédiatement
    if (cachedTasks.isNotEmpty) {
      emit(TaskLoaded(cachedTasks));
    }

    // 🔹 2. Vérifier si on doit rafraîchir les données
    final shouldFetch = cachedTasks.isEmpty ||
        (lastFetchTime == null || (currentTime - lastFetchTime) >= AppConstants.cacheDuration);

    if (!shouldFetch) return; // Pas besoin d’appeler l’API

    if (cachedTasks.isEmpty) {
      emit(TaskLoading());
    }

    try {
      final freshTasks = await repository.fetchAll();
      if (freshTasks.isEmpty) {
        emit(TaskEmpty());
      } else {
        emit(TaskLoaded(freshTasks));
      }

      repository.localSource.saveTasks(freshTasks);
      repository.localSource.setLastFetchTime(currentTime);
    } catch (e) {
      if (cachedTasks.isEmpty) {
        emit(TaskError("Échec du chargement des tâches"));
      }
    }
  }


  Future<void> addTask(Task newTask) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = List<Task>.from(currentState.tasks)..add(newTask);
      emit(TaskLoaded(updatedTasks));
      try {
        final addedTask = await repository.add(newTask);
        final finalTasks = List<Task>.from(updatedTasks)
          ..remove(newTask)
          ..add(addedTask);

        emit(TaskLoaded(finalTasks));
      } catch (e) {
        emit(TaskLoaded(currentState.tasks)); // Annule en cas d'erreur
      }
    }
  }


  Future<void> deleteTask(String taskId) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks =
          currentState.tasks.where((task) => task.id != taskId).toList();
      emit(TaskLoaded(updatedTasks));

      try {
        await repository.delete(taskId);
      } catch (e) {
        emit(TaskLoaded(currentState.tasks));
      }
    }
  }
}
