import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsAPI {
  final _dio = Dio(BaseOptions(baseUrl: dotenv.env['GOOGLE_MAPS_ENDPOINT']!));
  final _googleMapsAPIKey = dotenv.env['API_KEY'];

  Future<Map<String, dynamic>> getAdressName(
      double latitude, double longitude) async {
    try {
      Response response = await _dio.get(
          'geocode/json?latlng=$latitude,$longitude&key=$_googleMapsAPIKey');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> searchPlace(String placeName) async {
    try {
      Response response = await _dio.get(
          'place/autocomplete/json?input=$placeName&key=$_googleMapsAPIKey&sessiontoken=123254251&components=country:eg');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeID) async {
    try {
      Response response = await _dio
          .get('place/details/json?placeid=$placeID&key=$_googleMapsAPIKey');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getDirectionDetails(
      LatLng originPoint, LatLng destinationPoint) async {
    try {
      Response response = await _dio.get(
          'directions/json?origin=${originPoint.latitude},${originPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&travelMode=driving&key=$_googleMapsAPIKey');
      return response.data;
    } catch (e) {
      return {};
    }
  }
}
