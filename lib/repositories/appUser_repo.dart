import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/appUser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

/**  listen to the returned stream to receive updates about the user's data
 * 
 * streamUser("someUserId").listen((appUser? user) {
  if (user != null) {
    // Handle the user data (e.g., update UI)
    print("User data updated: ${user.name}");
  } 
});

 * 
*/
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

  Future<appUser?> getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    DocumentSnapshot doc =
        await _db.collection('users').doc(currentUser.uid).get();
    if (!doc.exists) {
      return null;
    }
    return appUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
