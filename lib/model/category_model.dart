import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool isDeleted;
  final String idUser;

  CategoryModel({
    required this.id,
    required this.name,
    this.isDeleted = false,
    required this.idUser,
  });

  factory CategoryModel.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'],
      isDeleted: data['isDeleted'] ?? false,
      idUser: data['idUser'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDeleted': isDeleted,
      'idUser': idUser,
    };
  }
}