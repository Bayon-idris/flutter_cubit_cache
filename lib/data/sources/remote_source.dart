import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';
import '../models/task_model.dart';

class TaskRemoteSource {
  final Dio _dio;

  TaskRemoteSource(this._dio);

  Future<List<Task>> fetchTasks() async {
    final response = await _dio.get('${AppConstants.baseUrl}/todos');
    return (response.data as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> addTask(Task task) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/todos',
      data: task.toJson(),
    );
    return Task.fromJson(response.data);
  }

  Future<Task> updateTask(Task task) async {
    final response = await _dio.put(
      '${AppConstants.baseUrl}/todos/${task.id}',
      data: task.toJson(),
    );
    return Task.fromJson(response.data);
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('${AppConstants.baseUrl}/todos/$id');
  }
}
