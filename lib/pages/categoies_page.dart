import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/controller/category_controller.dart';
import 'package:to_do_list/model/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final controller = CategoryController();

  @override
  void initState() {
    super.initState();
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    controller.loadCategories(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Categories")),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? Center(child: Text("Error: ${controller.errorMessage}"))
              : controller.categories.isEmpty
              ? const Center(child: Text("Tidak ada kategori"))
              : ListView.builder(
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteCategory(category.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              _showAddCategoryDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nama Kategori",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final userId = FirebaseAuth.instance.currentUser!.uid;
              final category = CategoryModel(
                id: "",
                name: nameController.text,
                idUser: userId,
                isDeleted: false,
                createdAt: DateTime.now(),
              );

              await controller.addCategory(category);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
