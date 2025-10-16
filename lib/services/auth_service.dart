import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String? userImageUrl,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid == null) {
        return "Gagal membuat user (uid null)";
      }

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'fullName': fullName,
        'email': email,
        'isDeleted': false,
        'userImageUrl': userImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Email sudah terdaftar, silakan gunakan email lain.";
      } else if (e.code == 'weak-password') {
        return "Password terlalu lemah";
      } else if (e.code == 'invalid-email') {
        return "Format email tidak valid";
      }
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        return "Gagal melakukan autentikasi";
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        return "Akun tidak ditemukan di database";
      }

      final data = doc.data()!;
      final bool isDeleted = data['isDeleted'] == true;

      if (isDeleted) {
        await _auth.signOut();
        return "Akun telah dihapus. Hubungi admin untuk pemulihan.";
      }

      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "User tidak ditemukan";
      } else if (e.code == 'wrong-password') {
        return "Password salah";
      } else if (e.code == 'invalid-email') {
        return "Format email tidak valid";
      }
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  Future<String?> softDeleteUser(String targetUid, {bool signOutIfCurrent = true}) async {
    try {
      final userDocRef = _firestore.collection('users').doc(targetUid);

      final snapshot = await userDocRef.get();
      if (!snapshot.exists) {
        return "User tidak ditemukan di database";
      }

      await userDocRef.update({'isDeleted': true});

      if (signOutIfCurrent && _auth.currentUser?.uid == targetUid) {
        await _auth.signOut();
      }

      return null;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  Future<String?> restoreUser(String targetUid) async {
    try {
      final userDocRef = _firestore.collection('users').doc(targetUid);
      final snapshot = await userDocRef.get();
      if (!snapshot.exists) return "User tidak ditemukan.";

      await userDocRef.update({'isDeleted': false});
      return null;
    } catch (e) {
      return "Gagal memulihkan akun: $e";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
