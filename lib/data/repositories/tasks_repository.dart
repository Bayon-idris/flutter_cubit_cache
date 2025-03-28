import '../models/task_model.dart';
import '../sources/local_source.dart';
import '../sources/remote_source.dart';
import 'base_repository.dart';

class TaskRepository implements BaseRepository<Task> {
  final TaskRemoteSource remoteSource;
  final TaskLocalSource localSource;

  TaskRepository({required this.remoteSource, required this.localSource});

  @override
  Future<List<Task>> fetchAll() async {
    final cachedTasks = localSource.getTasks();
    if (cachedTasks.isNotEmpty) {
      return cachedTasks;
    }

    final tasks = await remoteSource.fetchTasks();
    await localSource.saveTasks(tasks);

    return tasks;
  }

  @override
  Future<Task> add(Task task) async {
    final newTask = await remoteSource.addTask(task);
    final updatedTasks = [...localSource.getTasks(), newTask];

    await localSource.saveTasks(updatedTasks);
    return newTask;
  }

  @override
  Future<void> delete(String id) async {
    await remoteSource.deleteTask(id);
    final updatedTasks =
    localSource.getTasks().where((task) => task.id != id).toList();

    await localSource.saveTasks(updatedTasks);
  }
}
