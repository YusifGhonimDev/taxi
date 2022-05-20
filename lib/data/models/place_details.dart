class PlaceDetails {
  String? name;
  String? id;
  double? latitude;
  double? longitude;

  PlaceDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['place_id'];
    latitude = json['geometry']['location']['lat'];
    longitude = json['geometry']['location']['lng'];
  }
}
