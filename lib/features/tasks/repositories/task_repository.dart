import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/task.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepository(ref.watch(apiServiceProvider));
});

class TaskRepository {
  final ApiService _api;

  TaskRepository(this._api);

  Future<List<Task>> getTasks() async {
    final response = await _api.get('/tasks');
    // The API returns { "data": [...], "pagination": {...} }
    final List list = response.data['data'];
    return list.map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> createTask(String title, String description) async {
    final response = await _api.post('/tasks', data: {
      'title': title,
      'description': description,
    });
    return Task.fromJson(response.data);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final response = await _api.patch('/tasks/$id', data: data);
    return Task.fromJson(response.data);
  }

  Future<void> deleteTask(int id) async {
    await _api.delete('/tasks/$id');
  }
}