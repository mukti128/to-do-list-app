import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  String? userImageUrl;
  String? fullName;
  String? email;
  bool isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        userImageUrl = doc.data()?['userImageUrl'] ?? '';
        fullName = doc.data()?['fullName'] ?? '';
        email = doc.data()?['email'] ?? '';
      }
    } catch (e) {
      debugPrint('❌ Error loadUserProfile: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur editt profile belum diimplementsaikan 😊'),
      ),
    );
  }

  void openSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur settings belum diimplementasikan ⚙️'),
      ),
    );
  }
}
