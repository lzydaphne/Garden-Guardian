import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart'; // For date formatting

// Define a Plant class to hold plant details
class Plant {
  String species;
  DateTime plantingDate;
  int wateringCycle; // in days
  int fertilizationCycle; // in days
  int pruningCycle; // in days

  Plant(this.species, this.plantingDate, this.wateringCycle,
      this.fertilizationCycle, this.pruningCycle);
}

// Function to process the image and identify the plant species
// Future<String> identifyPlantSpecies(String imagePath) async {
//   // This function will use the GPT-4 model to identify the species
//   // Implementation will depend on how you interact with the GPT-4 model
//   // For now, we will assume a placeholder implementation
//   String species = await getPlantSpeciesFromImage(imagePath);
//   return species;
// }

// Placeholder for actual implementation
// Future<String> getPlantSpeciesFromImage(String imagePath) async {
//   // Implement your image recognition logic here
//   return "Ficus lyrata"; // Placeholder species name
// }

//* deliberately use "plantingDate" in case user reports "i watered the plant yesterday" or "i fertilized the plant last week"
// Function to calculate the next care dates
String calculateNextCareDatesTool(String lastActionDate, int wateringCycle,
    int fertilizationCycle, int pruningCycle) {
  // DateTime today = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime parsedLastActionDate = formatter.parse(lastActionDate);

  DateTime nextWateringDate =
      parsedLastActionDate.add(Duration(days: wateringCycle));
  DateTime nextFertilizationDate =
      parsedLastActionDate.add(Duration(days: fertilizationCycle));
  DateTime? nextPruningDate = pruningCycle > 0
      ? parsedLastActionDate.add(Duration(days: pruningCycle))
      : null;

  // Formatting the date for a nice output
  String formattedString = 'Next Care Dates:\n'
      'Next Watering Date: ${DateFormat('yyyy-MM-dd').format(nextWateringDate)}\n'
      'Next Fertilization Date: ${DateFormat('yyyy-MM-dd').format(nextFertilizationDate)}\n'
      'Next Pruning Date: ${nextPruningDate != null ? DateFormat('yyyy-MM-dd').format(nextPruningDate) : "No need to prune!"}';
  return formattedString;
}

Map<String, DateTime?> calculateNextCareDates(DateTime plantingDate,
    int wateringCycle, int fertilizationCycle, int pruningCycle) {
  // DateTime today = DateTime.now();
  DateTime nextWateringDate = plantingDate.add(Duration(days: wateringCycle));
  DateTime nextFertilizationDate =
      plantingDate.add(Duration(days: fertilizationCycle));
  DateTime? nextPruningDate =
      pruningCycle > 0 ? plantingDate.add(Duration(days: pruningCycle)) : null;

  return {
    "nextWateringDate": nextWateringDate,
    "nextFertilizationDate": nextFertilizationDate,
    "nextPruningDate": nextPruningDate,
  };
}

// Function to add a new plant
Future<String> addNewPlant(String species, int wateringCycle,
    int fertilizationCycle, int pruningCycle) async {
  DateTime plantingDate = DateTime.now();
  Plant newPlant = Plant(
      species, plantingDate, wateringCycle, fertilizationCycle, pruningCycle);

  Map<String, DateTime?> careDates = calculateNextCareDates(
      plantingDate, wateringCycle, fertilizationCycle, pruningCycle);

  // Formatting the date for a nice output
  String formattedString = 'Plant Details:\n'
      'Species: ${newPlant.species}\n'
      'Planting Date: ${DateFormat('yyyy-MM-dd').format(newPlant.plantingDate)}\n'
      'Watering Cycle: ${newPlant.wateringCycle} days\n'
      'Fertilization Cycle: ${newPlant.fertilizationCycle} days\n'
      'Pruning Cycle: ${newPlant.pruningCycle > 0 ? newPlant.pruningCycle.toString() + " days" : "No need to prune!"}\n'
      'Next Watering Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextWateringDate"]!)}\n'
      'Next Fertilization Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextFertilizationDate"]!)}\n'
      'Next Pruning Date: ${careDates["nextPruningDate"] != null ? DateFormat('yyyy-MM-dd').format(careDates["nextPruningDate"]!) : "No need to prune!"}';

  return formattedString;
}
