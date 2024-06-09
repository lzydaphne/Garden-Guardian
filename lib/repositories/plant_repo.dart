import 'package:flutter_app/models/plant.dart';

class PlantRepository {
  List<Plant> plants = [];

  void addPlant(String name, String locationId, String avatarUrl) {
    plants.add(Plant(name: name, locationId: locationId, avatarUrl: avatarUrl));
  }

  List<Plant> getPlantsByLocation(String locationId) {
    return plants.where((plant) => plant.locationId == locationId).toList();
  }
}