import 'package:flutter/material.dart';

class Genre {
  final String name;
  final String value;
  final Icon icon;

  Genre({this.name, this.value, this.icon});

  String get genreName => this.name;

  String get genreValue => this.value;

  Icon get genreIcon => this.icon;
}
