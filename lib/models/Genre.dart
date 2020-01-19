import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class Genre extends Taggable {
  final String name;
  final String value;
  final Icon icon;

  Genre({this.name, this.value, this.icon});

  String get genreName => this.name;

  String get genreValue => this.value;

  Icon get genreIcon => this.icon;

  @override
  List<Object> get props => [name];
}
