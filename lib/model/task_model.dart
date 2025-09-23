import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final String? categoryId;
  final bool isPinned;
  final bool isDone;
  final bool isDeleted;
  final String idUser;

  TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.dueDate,
    this.reminderTime,
    this.categoryId,
    required this.isPinned,
    required this.isDone,
    this.isDeleted = false,
    required this.idUser,
  });

  factory TaskModel.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
      categoryId: data['categoryId'],
      isPinned: data['isPinned'] ?? false,
      isDone: data['isDone'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      idUser: data['idUser'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'reminderTime': reminderTime,
      'categoryId': categoryId,
      'isPinned': isPinned,
      'isDone': isDone,
      'isDeleted': isDeleted,
      'idUser': idUser,
    };
  }
}
