import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/pages/add_task_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? selectedCategoryId;

  String _getMonthName(int month) {
    const bulan = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des",
    ];
    return bulan[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "search") {
              } else if (value == "manage_category") {}
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "search", child: Text("Search")),
              const PopupMenuItem(
                value: "manage_category",
                child: Text("Manajemen Kategori"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .where('idUser', isEqualTo: currentUserId)
                .where('isDeleted', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Gagal memuat ketegori"),
                );
              }
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              final categories = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Semua"),
                      selected: selectedCategoryId == null,
                      onSelected: (value) {
                        setState(() => selectedCategoryId = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat['name']),
                          selected: selectedCategoryId == cat.id,
                          onSelected: (value) {
                            setState(() => selectedCategoryId = cat.id);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategoryId == null
                  ? FirebaseFirestore.instance
                        .collection('tasks')
                        .where('idUser', isEqualTo: currentUserId)
                        .where('isDeleted', isEqualTo: false)
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                  : FirebaseFirestore.instance
                        .collection('tasks')
                        .where('idUser', isEqualTo: currentUserId)
                        .where('categoryId', isEqualTo: selectedCategoryId)
                        .where('isDeleted', isEqualTo: false)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Gagal memuat task"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs;
                if (tasks.isEmpty) {
                  return const Center(child: Text("Tidak ada task"));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final createdAt = task['createdAt'] as Timestamp?;

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
                          task['title'] ?? "Tanpa Judul",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: createdAt != null
                            ? Text(
                                "${createdAt.toDate().day} "
                                "${_getMonthName(createdAt.toDate().month)} "
                                "${createdAt.toDate().year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () {},
                        ),
                        onTap: () {},
                      ),
                    );
                  },
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
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
