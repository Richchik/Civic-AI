import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addIssue({
    required String title,
    required String description,
    required String location,
    required String imageUrl,
  }) async {
    await _db.collection('issues').add({
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
