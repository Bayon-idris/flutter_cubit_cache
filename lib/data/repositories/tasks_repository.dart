import '../sources/remote_source.dart';
import 'base_repository.dart';
import '../models/task_model.dart';

class TaskRepository implements BaseRepository<Task> {
  final TaskRemoteSource remoteSource;

  TaskRepository({required this.remoteSource});

  @override
  Future<List<Task>> fetchAll() => remoteSource.fetchTasks();

  @override
  Future<Task> add(Task task) => remoteSource.addTask(task);

  @override
  Future<Task> update(Task task) => remoteSource.updateTask(task);

  @override
  Future<void> delete(String id) => remoteSource.deleteTask(id);
}
