class Prediction {
  String? id;
  String? mainText;
  String? secondaryText;

  Prediction.fromJson(Map<String, dynamic> json) {
    id = json['place_id'];
    mainText = json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
  }
}
