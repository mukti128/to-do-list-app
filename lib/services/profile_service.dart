import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final CollectionReference userRef = FirebaseFirestore.instance.collection('users');
}