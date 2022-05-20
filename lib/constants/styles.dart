import 'package:flutter/material.dart';

const drawerItemStyle = TextStyle(fontSize: 16);
const boxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16), topRight: Radius.circular(16)),
  boxShadow: [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 16,
      spreadRadius: 0.8,
      offset: Offset(0.7, 0.7),
    ),
  ],
);
