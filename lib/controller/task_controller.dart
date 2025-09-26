import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/model/task_model.dart';
import 'package:to_do_list/services/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadTasks(String userId, {String? categoryId}) async {
    _setLoading(true);
    _setError(null);

    try {
      final allTasks = await _taskService.getTask().first;
      _tasks = allTasks
          .where((t) => t.idUser == userId)
          .where((t) => categoryId == null || t.categoryId == categoryId)
          .toList();
    } catch (e) {
      _setError("Gagal memuat task: $e");
    }

    _setLoading(false);
  }

  Future<bool> addTask({
    required String title,
    DateTime? dueDate,
    DateTime? reminderTime,
    String? categoryId,
  }) async {
    _setSaving(true);
    _setError(null);

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();

    final task = TaskModel(
      id: "",
      title: title,
      createdAt: now,
      dueDate: dueDate,
      reminderTime: reminderTime,
      categoryId: categoryId,
      isPinned: false,
      isDone: false,
      isDeleted: false,
      idUser: currentUserId,
    );

    try {
      await _taskService.addTask(task);
      await loadTasks(currentUserId, categoryId: categoryId);
      _setSaving(false);
      return true;
    } catch (e) {
      _setError("Gagal menambahkan task: $e");
      _setSaving(false);
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    _setSaving(true);
    _setError(null);
    try {
      await _taskService.updateTask(task);
      await loadTasks(task.idUser, categoryId: task.categoryId);
      _setSaving(false);
      return true;
    } catch (e) {
      _setError("Gagal mengupdate task: $e");
      _setSaving(false);
      return false;
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskService.softDeleteTask(id);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await loadTasks(currentUserId);
  }
}
