import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _titleController.text,
        'categoryId': selectedCategoryId,
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'reminder': reminderTime != null
            ? Timestamp.fromDate(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  reminderTime!.hour,
                  reminderTime!.minute,
                ),
              )
            : null,
        'isDeleted': false,
        'idUser': currentUserId,
      });

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
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data?.docs ?? [];
                    return DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: "Kategori (Opsional)",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("Tanpa kategori"),
                        ),
                        ...categories.map((cat) {
                          return DropdownMenuItem(
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
                    onPressed: _saveTask,
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Task"),
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
