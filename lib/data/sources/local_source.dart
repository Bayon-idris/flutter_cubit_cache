import 'package:hive/hive.dart';

import '../models/task_model.dart';

class TaskLocalSource {
  static const String _boxName = 'tasksBox';
  late Box<Task> _taskBox;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>(_boxName);
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await _taskBox.clear();
    for (var task in tasks) {
      await _taskBox.put(task.id, task);
    }
  }

  List<Task> getTasks() {
    return _taskBox.values.toList();
  }

  Future<void> clearTasks() async {
    await _taskBox.clear();
  }

  Future<void> setLastFetchTime(int currentTime) async {
    final box = await Hive.openBox('taskCacheMetadata');
    await box.put('lastFetchTime', currentTime);
  }


  int? getLastFetchTime() {
    final box = Hive.box('taskCacheMetadata');
    return box.get('lastFetchTime') as int?;
  }
}
