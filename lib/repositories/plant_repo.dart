import 'package:flutter_app/models/plant.dart';

class PlantRepository {
  List<Plant> plants = [];

  void addPlant(String name, String locationId) {
    plants.add(Plant(name: name, locationId: locationId));
  }

  List<Plant> getPlantsByLocation(String locationId) {
    return plants.where((plant) => plant.locationId == locationId).toList();
  }
}