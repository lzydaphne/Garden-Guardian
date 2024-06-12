import 'package:flutter_app/models/plant.dart';

class PlantRepository {
  List<Plant> plants = [];

  void addPlant(String name, String locationId, String avatarUrl, String? type) {
    plants.add(Plant(name: name, locationId: locationId, avatarUrl: avatarUrl, type: type));
  }

  List<Plant> getPlantsByLocation(String locationId) {
    return plants.where((plant) => plant.locationId == locationId).toList();
  }
}