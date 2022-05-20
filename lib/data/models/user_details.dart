import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  String? email;
  String? name;
  String? phoneNumber;

  UserDetails.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    email = snapshot['email'];
    name = snapshot['fullName'];
    phoneNumber = snapshot['phoneNumber'];
  }
}
