import 'package:flutter/services.dart';

class UpiApp {
  final String packageName;
  final String name;
  final Uint8List icon;

  UpiApp({required this.packageName, required this.name, required this.icon});

  factory UpiApp.fromMap(Map<String, dynamic> map) {
    return UpiApp(
      packageName: map['packageName'],
      name: map['name'],
      icon: map['icon'],
    );
  }
}
