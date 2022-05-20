import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/data/data_providers/maps_api.dart';
import 'package:taxi/data/models/address.dart';
import 'package:taxi/data/models/direction_details.dart';
import 'package:taxi/data/models/place_details.dart';
import 'package:taxi/data/models/predictions.dart';

class MapsRepository {
  final _mapsAPI = MapsAPI();

  Future<Address> getAddressName(double latitude, double longitude) async {
    Map<String, dynamic> json =
        await _mapsAPI.getAdressName(latitude, longitude);
    Map<String, dynamic> addressName = json['results'][0];
    return Address.fromJson(addressName);
  }

  Future<List<Prediction>> searchPlace(String placeName) async {
    Map<String, dynamic> json = await _mapsAPI.searchPlace(placeName);
    List<dynamic> predictions = json['predictions'];
    return predictions.map((e) => Prediction.fromJson(e)).toList();
  }

  Future<PlaceDetails> getPlaceDetails(String placeID) async {
    Map<String, dynamic> json = await _mapsAPI.getPlaceDetails(placeID);
    Map<String, dynamic> placeDetails = json['result'];
    return PlaceDetails.fromJson(placeDetails);
  }

  Future<DirectionDetails> getDirectionDetails(
      LatLng originPoint, LatLng destinationPoint) async {
    Map<String, dynamic> json =
        await _mapsAPI.getDirectionDetails(originPoint, destinationPoint);
    Map<String, dynamic> directionDetails = json['routes'][0];
    return DirectionDetails.fromJson(directionDetails);
  }
}
