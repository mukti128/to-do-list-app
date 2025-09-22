import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime reminderTime;
  final String? categoryId;
  final bool isDone;
  final bool isDeleted;
  final String idUser;

  TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.dueDate,
    required this.reminderTime,
    this.categoryId,
    required this.isDone,
    this.isDeleted = false,
    required this.idUser,
  });

  factory TaskModel.fromFireStore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      reminderTime: (data['reminderTime'] as Timestamp).toDate(),
      categoryId: data['categoryId'],
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
      if (categoryId != null) 'categoryId': categoryId,
      'isDone': isDone,
      'isDeleted': isDeleted,
      'idUser': idUser,
    };
  }
}