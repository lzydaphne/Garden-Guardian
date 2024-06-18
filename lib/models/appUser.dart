import 'package:cloud_firestore/cloud_firestore.dart';

class appUser {
  final String? id;
  final String userName;
  int cnt_signin;
  int cnt_watering;
  int cnt_plantNum;
  int cnt_plantType;
  int cnt_drink;

  appUser({
    this.id,
    required this.userName,
    required this.cnt_signin,
    required this.cnt_watering,
    required this.cnt_plantNum,
    required this.cnt_plantType,
    required this.cnt_drink,
  });

  factory appUser.fromMap(Map<String, dynamic> map) {
    return appUser(
      id: map['id'],
      userName: map['userName'],
      cnt_signin: map['cnt_signin'],
      cnt_watering: map['cnt_watering'],
      cnt_plantNum: map['cnt_plantNum'],
      cnt_plantType: map['cnt_plantType'],
      cnt_drink: map['cnt_drink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'cnt_signin': cnt_signin,
      'cnt_watering': cnt_watering,
      'cnt_plantNum': cnt_plantNum,
      'cnt_plantType': cnt_plantType,
      'cnt_drink': cnt_drink,
    };
  }
}
