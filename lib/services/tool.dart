import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:image_picker/image_picker.dart';

import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/models/plant.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_functions/cloud_functions.dart';

// import 'package:flutter_app/repositories/message_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/repositories/plant_repo.dart';
import 'package:flutter_app/repositories/appUser_repo.dart';
import 'package:flutter_app/models/appUser.dart';

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
Future<String> addNewPlant(
    String species,
    String imageUrl,
    int wateringCycle,
    int fertilizationCycle,
    int pruningCycle,
    PlantRepository _plantRepository) async {
  DateTime plantingDate = DateTime.now();

  Map<String, DateTime?> careDates = calculateNextCareDates(
      plantingDate, wateringCycle, fertilizationCycle, pruningCycle);

  Plant newPlant = Plant(
    nickName: 'wait to be updated',
    species: species,
    imageUrl: imageUrl,
    plantingDate: plantingDate,
    wateringCycle: wateringCycle,
    fertilizationCycle: fertilizationCycle,
    pruningCycle: pruningCycle,
    lastCareDate:
        plantingDate, //! [TODO] should be updated when user reports new care
    nextWateringDate: careDates["nextWateringDate"],
    nextFertilizationDate: careDates["nextFertilizationDate"],
    nextPruningDate: careDates["nextPruningDate"],
  );

  //! add to database
  await _plantRepository.addPlant(newPlant);
  debugPrint("Plant added to DB successfully");

  // Formatting the date for a nice output
  String formattedString = 'Plant Details:\n'
      'Species: ${newPlant.species}\n'
      'Planting Date: ${DateFormat('yyyy-MM-dd').format(newPlant.plantingDate ?? DateTime.now())}\n'
      'Watering Cycle: ${newPlant.wateringCycle} days\n'
      'Fertilization Cycle: ${newPlant.fertilizationCycle} days\n'
      'Pruning Cycle: ${newPlant.pruningCycle! > 0 ? newPlant.pruningCycle.toString() + " days" : "No need to prune!"}\n'
      'Next Watering Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextWateringDate"]!)}\n'
      'Next Fertilization Date: ${DateFormat('yyyy-MM-dd').format(careDates["nextFertilizationDate"]!)}\n'
      'Next Pruning Date: ${careDates["nextPruningDate"] != null ? DateFormat('yyyy-MM-dd').format(careDates["nextPruningDate"]!) : "No need to prune!"}';

  return formattedString;
}

Future<String> storeNickname(String nickname) async {
  // store nickname for latest added plant
  PlantRepository plantRepository = PlantRepository();
  String? targetPlantID = await plantRepository.getLatestPlantID();
  if (targetPlantID == null) {
    throw Exception('Plant not found');
  }
  // Update the plant's nickname
  await plantRepository.updatePlant(targetPlantID, {'nickName': nickname});

  return 'Nickname updated successfully!';
}

Future<String> counting_goal(String behavior, String lastCareDate,
    int wateringCycle, int fertilizationCycle, int pruningCycle) async {
  AppUserRepository userRepository = AppUserRepository();
  appUser? user = await userRepository
      .getCurrentAppUser("test"); //! [TODO] need to dynamically change
  // Handle user behavior counting
  if (user == null) {
    throw Exception('User not found');
  }
  debugPrint('User found: ${user.userName}');
  switch (behavior) {
    case 'watering':
      user.cnt_watering += 1;

      // Update the user in Firestore
      await userRepository.createOrUpdateUser(user);
      debugPrint(
          'User updated successfully, user.cnt_watering: ${user.cnt_watering}');
      break;
    // case 'plantNum':
    //   user?.cnt_plantNum = user.cnt_plantNum ?? 0 + 1;
    //   break;
    // case 'plantType':
    //   user?.cnt_plantType = user.cnt_plantType ?? 0 + 1;
    //   break;
    // case 'drink': //! [TODO] connect with water page to count drink
    //   user?.cnt_drink = user.cnt_drink ?? 0 + 300;
    //   break;
    default:
      throw ArgumentError('Unknown behavior: $behavior');
  }

  DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime parsedLastActionDate = formatter.parse(lastCareDate);

  DateTime nextWateringDate =
      parsedLastActionDate.add(Duration(days: wateringCycle));
  DateTime nextFertilizationDate =
      parsedLastActionDate.add(Duration(days: fertilizationCycle));
  DateTime? nextPruningDate = pruningCycle > 0
      ? parsedLastActionDate.add(Duration(days: pruningCycle))
      : null;

  // Formatting the date for a nice output
  String formattedString = 'Next Care Dates:\n'
      'Next Watering Date: ${formatter.format(nextWateringDate)}\n'
      'Next Fertilization Date: ${formatter.format(nextFertilizationDate)}\n'
      'Next Pruning Date: ${nextPruningDate != null ? DateFormat('yyyy-MM-dd').format(nextPruningDate) : "No need to prune!"}';

  // Return a map containing user and formatted string
  return formattedString;
}

/*
// deliberately use "plantingDate" in case user reports "i watered the plant yesterday" or "i fertilized the plant last week"
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
 */

Future<Message> findSimilarMessage(String query) async {
  debugPrint('Finding and appending similar message for query: $query');

  final results = await _vectorSearch(query);

  if (results == null) {
    debugPrint("Memory database is empty");

    String systemHeader =
        "The database is empty , can't retrieved information of pass conversation."; // system header for retrieve memory
    return Message(
        text: systemHeader,
        role: 'system',
        imageDescription: null,
        base64ImageUrl: null); // can't be assistant or system , both failed
  } else {
    String systemHeader =
        "Retrieved memory from database , it may be helpful or not to your response :there is a prompt of ${results.role} , in ${results.timeStamp}, it says : "; // system header for retrieve memory
    return Message(
        text: systemHeader + results.text,
        role: 'system',
        imageDescription: results.imageDescription,
        base64ImageUrl: results
            .base64ImageUrl); // can't be assistant or system , both failed
  }
}

Future<Message?> _vectorSearch(String searchString) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    debugPrint('Signed in anonymously as: ${userCredential.user?.uid}');

    debugPrint('Performing vector search');

    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('ext-firestore-vector-search-queryCallable');

    final response = await callable.call(<String, dynamic>{
      //add a prefilter with username != null (don;t consider system message)
      'query': searchString,
      'limit': 1,
      'prefilters': [
        {
          'field': 'issystem',
          'operator': '==', // can't use != , not supported in vector search
          'value': "0",
        },
      ],
    });
    debugPrint('Vector search response: ${response.data}');

    debugPrint(
        'Fetching message from Firestore with ID: ${response.data['ids'][0]}');
    final docSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(response.data['ids'][0])
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return Message.fromMap(data ?? {});
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('Error in vector search: $e');
  }
  return null;
}
