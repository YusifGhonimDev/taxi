import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  String? email, name, geoHash, carColor, carModel, phoneNumber, carNumber;
  GeoPoint? geoPoint;
  double? latitude, longitude;

  Driver(
      {required this.latitude, required this.longitude, required this.geoHash});

  Driver.fromSnapshot(snapshot) {
    email = snapshot['email'];
    name = snapshot['full_name'];
    geoHash = snapshot['position']['geohash'];
    carColor = snapshot['vehicleInfo']['color'];
    carModel = snapshot['vehicleInfo']['model'];
    phoneNumber = snapshot['phoneNumber'];
    carNumber = snapshot['vehicleInfo']['number'];
    geoPoint = snapshot['position']['geopoint'];
    latitude = geoPoint!.latitude;
    longitude = geoPoint!.longitude;
  }
}
