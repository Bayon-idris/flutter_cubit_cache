import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_cache/presentation/cubits/tasks_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit({required this.repository}) : super(TaskInitial());

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
  Future<void> addTask(Task task) async {
    try {
      await repository.add(task);
      fetchTasks(); // Rafraîchir la liste
    } catch (e) {
      emit(TaskError('Erreur lors de l\'ajout de la tâche'));
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
  Future<void> deleteTask(String id) async {
    try {
      await repository.delete(id);
      fetchTasks(); // Rafraîchir
    } catch (e) {
      emit(TaskError('Erreur lors de la suppression de la tâche'));
    }
  }
}
