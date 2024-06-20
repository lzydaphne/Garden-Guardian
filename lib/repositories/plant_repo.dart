import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/plant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PlantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

/*
 * can be used to listen to the returned stream to receive updates about the plant's data
 */
  Stream<List<Plant>> streamAllPlants() {
    return _db
        .collection('plants')
        .orderBy('plantingDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Plant.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> addPlant(Plant plant) async {
    try {
      DocumentReference docRef =
          await _db.collection('plants').add(plant.toMap());
      String generatedId = docRef.id;
      // Update the document with the generated ID
      await docRef.update({'id': generatedId});
      print('Plant updated with ID: $generatedId');
    } catch (e) {
      print('Error adding plant: $e');
    }
  }

  Future<void> updatePlant(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('plants').doc(id).update(data);
      print('Plant updated with ID: $id');
    } catch (e) {
      print('Error updating plant: $e');
    }
  }

  Future<void> deletePlant(String id) async {
    try {
      await _db.collection('plants').doc(id).delete();
      print('Plant deleted with ID: $id');
    } catch (e) {
      print('Error deleting plant: $e');
    }
  }

  Future<String?> getLatestPlantID() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('plants')
          .orderBy('plantingDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting latest plant: $e');
      return null;
    }
  }

  Future<List<Plant>> getAllPlants() async {
    try {
      QuerySnapshot snapshot = await _db.collection('plants').get();
      return snapshot.docs
          .map((doc) => Plant.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all plants: $e');
      return [];
    }
  }

  Future<List<Plant>> getPlantsByLocation(String locationId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('plants')
          .where('locationId', isEqualTo: locationId)
          .get();
      return snapshot.docs
          .map((doc) => Plant.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting plants by location: $e');
      return [];
    }
  }
}



//* [TODO] FIX this to work
// class PlantRepository {
//   List<Plant> plants = [];

//   void addPlant(String name, String locationId, String avatarUrl) {
//     plants.add(Plant(nickName: name, locationId: locationId, imageUrl: avatarUrl));
//   }

//   List<Plant> getPlantsByLocation(String locationId) {
//     return plants.where((plant) => plant.locationId == locationId).toList();
//   }
// }

