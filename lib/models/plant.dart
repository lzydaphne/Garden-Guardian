
import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String? id;
  final String? nickName;
  final String? locationId;
  final String species;
  final String imageUrl;
  final int wateringCycle; // in days
  final int fertilizationCycle; // in days
  final int pruningCycle; // in days
  final DateTime? plantingDate;
  final DateTime? nextWateringDate;
  final DateTime? nextFertilizationDate;
  final DateTime? nextPruningDate;

  Plant({
    this.id,
    this.nickName,
    this.locationId,
    required this.species,
    required this.imageUrl,
    required this.wateringCycle,
    required this.fertilizationCycle,
    required this.pruningCycle,
    this.plantingDate,
    this.nextWateringDate,
    this.nextFertilizationDate,
    this.nextPruningDate,
  });

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      nickName: map['nickName'],
      locationId: map['locationId'],
      species: map['species'],
      imageUrl: map['imageUrl'],
      plantingDate: (map['plantingDate'] as Timestamp).toDate(),
      wateringCycle: map['wateringCycle'],
      fertilizationCycle: map['fertilizationCycle'],
      pruningCycle: map['pruningCycle'],
      nextWateringDate: (map['nextWateringDate'] as Timestamp).toDate(),
      nextFertilizationDate:
          (map['nextFertilizationDate'] as Timestamp).toDate(),
      nextPruningDate: (map['nextPruningDate'] as Timestamp).toDate(),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'nickName': nickName,
      'locationId': locationId,
      'species': species,
      'imageUrl': imageUrl,
      'plantingDate': plantingDate,
      'wateringCycle': wateringCycle,
      'fertilizationCycle': fertilizationCycle,
      'pruningCycle': pruningCycle,
      'nextWateringDate': nextWateringDate,
      'nextFertilizationDate': nextFertilizationDate,
      'nextPruningDate': nextPruningDate,
    };
  }
}

