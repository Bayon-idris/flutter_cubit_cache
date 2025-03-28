import 'package:flutter_cubit_cache/core/utils/constants.dart';
import 'package:hive/hive.dart';

import '../models/task_model.dart';

class TaskLocalSource {
  Box<Task>? _taskBox;

  Future<void> init() async {
    _taskBox ??= await Hive.openBox<Task>(AppConstants.boxName);
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await init();
    await _taskBox!.clear();
    for (var task in tasks) {
      await _taskBox!.put(task.id, task);
    }
  }

  List<Task> getTasks() {
    if (_taskBox == null) return [];
    return _taskBox!.values.toList();
  }

  Future<void> clearTasks() async {
    await init();
    await _taskBox!.clear();
  }

  Future<void> setLastFetchTime(int currentTime) async {
    final box = await Hive.openBox('taskCacheMetadata');
    await box.put('lastFetchTime', currentTime);
  }

  Future<int?> getLastFetchTime() async {
    final box = await Hive.openBox('taskCacheMetadata');
    return box.get('lastFetchTime') as int?;
  }
}
