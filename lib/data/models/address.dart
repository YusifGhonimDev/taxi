class Address {
  String? addressName;

  Address.fromJson(Map<String, dynamic> json) {
    addressName = json['formatted_address'];
  }
}
