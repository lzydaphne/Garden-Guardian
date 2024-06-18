import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/appUser.dart';

class AppUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<appUser?> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      return snapshot.data() == null
          ? null
          : appUser.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<appUser?> getUserByEmail(String email) async {
    QuerySnapshot querySnapshot =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    return appUser.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
        querySnapshot.docs.first.id);
  }

  Future<void> updatePushMessagingToken(String userId, String? token) async {
    await _db
        .collection('users')
        .doc(userId)
        .update({'pushMessagingToken': token});
  }

  Future<void> createOrUpdateUser(appUser user) async {
    Map<String, dynamic> userMap = user.toMap();
    await _db
        .collection('users')
        .doc(user.id)
        .set(userMap); // write to local cache immediately
  }
}
