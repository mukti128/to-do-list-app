import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': _nameController.text,
        'isDeleted': false,
        'idUser': currentUserId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category berhasil ditambahkan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .where('idUser', isEqualTo: currentUserId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Gagal memuat kategori"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data!.docs;
              if (categories.isEmpty) {
                return const Center(child: Text("Tidak ada categori"));
              }

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

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
                        category['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
