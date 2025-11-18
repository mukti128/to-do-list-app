import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/controller/task_controller.dart';
import 'package:to_do_list/controller/category_controller.dart';
import 'package:to_do_list/models/task_model.dart';
import 'package:to_do_list/models/category_model.dart';
import 'package:to_do_list/pages/feature/add_task_page.dart';
import 'package:to_do_list/pages/feature/categoies_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final controller = TaskController();
  final categoryController = CategoryController();

  String? selectedCategoryId;

  String _getMonthName(int month) {
    const bulan = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return bulan[month - 1];
  }

  @override
  void initState() {
    super.initState();
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    controller.loadTasks(currentUserId, categoryId: selectedCategoryId);
    categoryController.loadCategories(currentUserId);
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => selectedCategoryId = categoryId);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    controller.loadTasks(currentUserId, categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, categoryController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Tasks"),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "manage_category") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoriesPage()),
                    ).then((_) {
                      final currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;
                      categoryController.loadCategories(currentUserId);
                      controller.loadTasks(
                        currentUserId,
                        categoryId: selectedCategoryId,
                      );
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "manage_category",
                    child: Text("Manajemen Kategori"),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (categoryController.categories.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryController.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: const Text("Semua"),
                            selected: selectedCategoryId == null,
                            onSelected: (_) => _onCategorySelected(null),
                          ),
                        );
                      }
                      final CategoryModel category =
                          categoryController.categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: selectedCategoryId == category.id,
                          onSelected: (_) => _onCategorySelected(category.id),
                        ),
                      );
                    },
                  ),
                ),

              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage != null
                    ? Center(child: Text("Error: ${controller.errorMessage}"))
                    : controller.tasks.isEmpty
                    ? const Center(child: Text("Tidak ada task"))
                    : ListView.builder(
                        itemCount: controller.tasks.length,
                        itemBuilder: (context, index) {
                          final TaskModel task = controller.tasks[index];

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
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "${task.createdAt.day} ${_getMonthName(task.createdAt.month)} ${task.createdAt.year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskPage()),
              );
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;
              controller.loadTasks(
                currentUserId,
                categoryId: selectedCategoryId,
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
