import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/model/task_model.dart';

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

  bool _isSaving = false;

  Future<void> _saveTask() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();

    DateTime? reminderDateTime;
    if (reminderTime != null) {
      reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime!.hour,
        reminderTime!.minute,
      );
    }

    final task = TaskModel(
      id: "",
      title: _titleController.text,
      createdAt: now,
      dueDate: dueDate,
      reminderTime: reminderDateTime,
      categoryId: selectedCategoryId,
      isPinned: false,
      isDone: false,
      isDeleted: false,
      idUser: currentUserId,
    );

    try {
      await FirebaseFirestore.instance.collection('tasks').add(task.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task berhasil ditambahkan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan task: $e')));
    }
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
                      initialValue: selectedCategoryId,
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveTask,
                    icon: const Icon(Icons.save),
                    label: _isSaving
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
