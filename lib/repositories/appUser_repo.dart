import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/appUser.dart';

class appUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<appUser>> streamAllUsers() {
    return _db
        .collection('users')
        // .orderBy('plantingDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => appUser.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> addUser(appUser user) async {
    try {
      DocumentReference docRef =
          await _db.collection('users').add(user.toMap());
      String generatedId = docRef.id;
      // Update the document with the generated ID
      await docRef.update({'id': generatedId});
      print('appUser updated with ID: $generatedId');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(id).update(data);
      print('appUser updated with ID: $id');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _db.collection('users').doc(id).delete();
      print('appUser deleted with ID: $id');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
