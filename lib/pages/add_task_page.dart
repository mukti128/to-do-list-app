import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/controller/task_controller.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String? selectedCategoryId;
  DateTime? dueDate;
  TimeOfDay? reminderTime;

  DateTime? _buildReminderDateTime() {
    if (reminderTime == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime!.hour,
      reminderTime!.minute,
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul task
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Nama Task",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Dropdown kategori
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .where('isDeleted', isEqualTo: false)
                      .where(
                        'idUser',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data?.docs ?? [];
                    return DropdownButtonFormField<String?>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: "Kategori (Opsional)",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("Tanpa kategori"),
                        ),
                        ...categories.map((cat) {
                          return DropdownMenuItem<String?>(
                            value: cat.id,
                            child: Text(cat['name']),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedCategoryId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dueDate == null
                            ? "Belum pilih tenggat"
                            : "Tenggat: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDueDate,
                      child: const Text("Pilih Tanggal"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminderTime == null
                            ? "Belum pilih pengingat"
                            : "Pengingat: ${reminderTime!.format(context)}",
                      ),
                    ),
                    TextButton(
                      onPressed: _pickReminder,
                      child: const Text("Pilih Jam"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            bool success = await controller.addTask(
                              title: _titleController.text,
                              dueDate: dueDate,
                              reminderTime: _buildReminderDateTime(),
                              categoryId: selectedCategoryId,
                            );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Task berhasil ditambahkan")),
                              );
                              Navigator.pop(context);
                            } else if (controller.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(controller.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: controller.isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Simpan Task"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
