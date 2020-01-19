import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class Influence extends Taggable {
  final String name;
  final String country;
  final String date;

  Influence({this.name, this.country, this.date});

  String get genreName => this.name;

  @override
  List<Object> get props => [name];

  factory Influence.fromJson(doc) {
    return Influence(
        name: doc['name']['\$t'].toString(),
        //country: doc['country']['\$t'].toString(),
        date: doc['life-span']['begin'].toString());
    // );
  }
}
