import 'package:flutter/material.dart';
import 'package:to_do_list/model/category_model.dart';
import 'package:to_do_list/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  void loadCategories(String userId) {
    isLoading = true;
    notifyListeners();

    _service
        .getCategories(userId)
        .listen(
          (data) {
            categories = data;
            isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            errorMessage = e.toString();
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addCategory(CategoryModel category) async {
    await _service.addCategory(category);
  }

  Future<void> deleteCategory(String id, String userId) async {
    await _service.softDeleteCategory(id, userId);
  }
}
