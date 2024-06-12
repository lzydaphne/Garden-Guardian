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

// Function to calculate the next care dates
Map<String, DateTime> calculateNextCareDates(DateTime plantingDate,
    int wateringCycle, int fertilizationCycle, int pruningCycle) {
  DateTime today = DateTime.now();
  DateTime nextWateringDate = plantingDate.add(Duration(days: wateringCycle));
  DateTime nextFertilizationDate =
      plantingDate.add(Duration(days: fertilizationCycle));
  DateTime nextPruningDate = plantingDate.add(Duration(days: pruningCycle));

  return {
    "nextWateringDate": nextWateringDate,
    "nextFertilizationDate": nextFertilizationDate,
    "nextPruningDate": nextPruningDate,
  };
}

// Function to add a new plant
Future<String> addNewPlant(String species, int wateringCycle,
    int fertilizationCycle, int pruningCycle) async {
  //! species can be returned from chat completion model
  // String species = await identifyPlantSpecies(imagePath);

  DateTime plantingDate = DateTime.now();
  // int wateringCycle = 7; // Example value, should be specific to the species
  // int fertilizationCycle =
  //     30; // Example value, should be specific to the species
  // int pruningCycle = 90; // Example value, should be specific to the species

  Plant newPlant = Plant(
      species, plantingDate, wateringCycle, fertilizationCycle, pruningCycle);

  Map<String, DateTime> careDates = calculateNextCareDates(
      plantingDate, wateringCycle, fertilizationCycle, pruningCycle);

  // Formatting the date for a nice output
  String formattedString = 'Plant Details:\n'
      'Species: ${newPlant.species}\n'
      'Planting Date: ${DateFormat('yyyy-MM-dd').format(newPlant.plantingDate)}\n'
      'Watering Cycle: ${newPlant.wateringCycle} days\n'
      'Fertilization Cycle: ${newPlant.fertilizationCycle} days\n'
      'Pruning Cycle: ${newPlant.pruningCycle} days\n'
      'Next Watering Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextWateringDate"]!)}\n'
      'Next Fertilization Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextFertilizationDate"]!)}\n'
      'Next Pruning Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextPruningDate"]!)}';

  return formattedString;

  // return {
  //   "species": newPlant.species,
  //   "plantingDate": DateFormat('yyyy-MM-dd').format(newPlant.plantingDate),
  //   "wateringCycle": newPlant.wateringCycle,
  //   "fertilizationCycle": newPlant.fertilizationCycle,
  //   "pruningCycle": newPlant.pruningCycle,
  //   "nextWateringDate":
  //       DateFormat('yyyy-MM-dd').format(careDates["nextWateringDate"]!),
  //   "nextFertilizationDate":
  //       DateFormat('yyyy-MM-dd').format(careDates["nextFertilizationDate"]!),
  //   "nextPruningDate":
  //       DateFormat('yyyy-MM-dd').format(careDates["nextPruningDate"]!),
  // };
}
