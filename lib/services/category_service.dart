import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/models/category_model.dart';

class CategoryService {
  final CollectionReference categoriesRef = FirebaseFirestore.instance
      .collection('categories');
  final CollectionReference tasksRef = FirebaseFirestore.instance.collection(
    'tasks',
  );

  Future<void> addCategory(CategoryModel category) async {
    await categoriesRef.add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await categoriesRef.doc(category.id).update(category.toMap());
  }

  Future<void> softDeleteCategory(String id, String userId) async {
    final batch = FirebaseFirestore.instance.batch();

    final categoryRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(id);
    batch.update(categoryRef, {'isDeleted': true});

    final taskQuery = await FirebaseFirestore.instance
        .collection('tasks')
        .where('categoryId', isEqualTo: id)
        .where('idUser', isEqualTo: userId)
        .get();

    for (var doc in taskQuery.docs) {
      batch.update(doc.reference, {'categoryId': null});
    }

    await batch.commit();
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
