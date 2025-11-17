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
      appBar: AppBar(
        title: const Text(
          'Tambah Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: "Nama Task",
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categories')
                              .where('isDeleted', isEqualTo: false)
                              .where(
                                'idUser',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid,
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final categories = snapshot.data?.docs ?? [];
                            return _buildDropDown(
                              label: "Kategori (Opsional)",
                              value: selectedCategoryId,
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
                              onChanged: (value) => 
                                  setState(() => selectedCategoryId = value),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildPickerButton(
                          title: "Tenggat",
                          value: dueDate == null
                              ? "Belum pilih"
                              : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
                          onTap: _pickDueDate,
                        ),

                        const SizedBox(height: 20),

                        _buildPickerButton(
                          title: "Pengingat",
                          value: reminderTime == null
                              ? "Belum pilih"
                              : reminderTime!.format(context),
                          onTap: _pickReminder,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        child: SizedBox(
          height: 55,
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
                        content: Text("Task berhasil ditambahkan"),
                      ),
                    );
                  } else if (controller.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(controller.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
            icon: controller.isSaving
                ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.save),
            label: const Text(
              "Simpan Task",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        )
      ),
    );
  }

  Widget _buildDropDown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const Icon(Icons.calendar_month, size: 22),
          ],
        ),
      ),
    );
  }
}
