import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_cache/presentation/cubits/tasks_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  static const int cacheDuration = 3600; // 1 hour in seconds

  TaskCubit({required this.repository}) : super(TaskInitial()) {
    fetchTasks();
  }

  void fetchTasks() async {
    final cachedTasks = repository.localSource.getTasks();
    final lastFetchTime = repository.localSource.getLastFetchTime();
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (cachedTasks.isNotEmpty && (currentTime - lastFetchTime!) < cacheDuration) {
      emit(TaskLoaded(cachedTasks));
    } else {
      try {
        final freshTasks = await repository.fetchAll();
        repository.localSource.saveTasks(freshTasks);
        repository.localSource.setLastFetchTime(currentTime);
        emit(TaskLoaded(freshTasks));
      } catch (e) {
        if (cachedTasks.isEmpty) {
          emit(TaskError("Échec du chargement des tâches"));
        }
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
        emit(TaskLoaded(currentState.tasks));
      }
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await repository.update(task);
      fetchTasks();
    } catch (e) {
      emit(TaskError('Erreur lors de la mise à jour de la tâche'));
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
