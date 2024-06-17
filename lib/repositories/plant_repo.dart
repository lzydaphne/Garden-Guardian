import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/plant.dart';

class PlantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}
// class PlantRepository {
//   List<Plant> plants = [];

//   void addPlant(String name, String locationId, String avatarUrl) {
//     plants.add(Plant(name: name, locationId: locationId, avatarUrl: avatarUrl));
//   }

//   List<Plant> getPlantsByLocation(String locationId) {
//     return plants.where((plant) => plant.locationId == locationId).toList();
//   }
// }

