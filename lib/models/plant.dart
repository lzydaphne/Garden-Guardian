class Plant{
  String?
    id;
  final String name;
  final String avatarUrl;
  final String locationId;
  String? type;
  String? moveInDate;
  String? lastWateredDate;
  String? lastFertilizedDate;
  String? lastPrunedDate;
  //to add more

  Plant({
    required this.name,
    required this.avatarUrl,
    required this.locationId,
    type,
    moveInDate,
    lastWateredDate,
    lastFertilizedDate,
    lastPrunedDate
  });


  Plant._({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.locationId,
  });

  factory Plant.fromMap(Map<String, dynamic> map, String? id){
    return Plant._(
      id: id,
      name: map['name'],
      avatarUrl: map['avatatUrl'],
      locationId: map['locationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'locationId': locationId,
    };
  }


}