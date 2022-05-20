class DirectionDetails {
  String? distanceText;
  int? distanceValue;
  String? durationText;
  int? durationValue;
  String? polylinePoints;

  DirectionDetails.fromJson(Map<String, dynamic> json) {
    distanceText = json['legs'][0]['distance']['text'];
    distanceValue = json['legs'][0]['distance']['value'];
    durationText = json['legs'][0]['duration']['text'];
    durationValue = json['legs'][0]['duration']['value'];
    polylinePoints = json['overview_polyline']['points'];
  }
}
