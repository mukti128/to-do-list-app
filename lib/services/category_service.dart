import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/model/category_model.dart';

class CategoryService {
  final CollectionReference categoriesRef = FirebaseFirestore.instance
      .collection('categories');

  Future<void> addCategory(CategoryModel category) async {
    await categoriesRef.add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await categoriesRef.doc(category.id).update(category.toMap());
  }

  Future<void> softDeleteCategory(String id) async {
    await categoriesRef.doc(id).update({'isDeleted': true});
  }

  Stream<List<CategoryModel>> getCategories(String userId) {
    return categoriesRef
        .where('isDeleted', isEqualTo: false)
        .where('idUser', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFireStore(doc))
              .toList(),
        );
  }
}
