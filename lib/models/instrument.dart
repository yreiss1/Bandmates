import 'package:flutter/material.dart';

class Instrument {
  final String name;
  final String value;
  final Icon icon;

  Instrument({this.name, this.value, this.icon});

  String get instrumentName => this.name;

  String get instrumentValue => this.value;

  Icon get instrumentIcon => this.icon;
}
