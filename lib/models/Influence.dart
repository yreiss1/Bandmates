import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class Influence extends Taggable {
  final String name;
  final String country;
  final String date;

  Influence({this.name, this.country, this.date});

  String get influenceName => this.name;

  @override
  List<Object> get props => [name];

  factory Influence.fromJson(doc) {
    String country;
    String begin;

    if (doc == null || doc['name'] == null || doc['name']['\$t'] == null) {
      return null;
    }
    if (doc['area'] != null && doc['area']['name']['\$t'] != null) {
      country = doc['area']['name']['\$t'].toString();
    }

    if (doc['life-span'] != null &&
        doc['life-span']['begin'] != null &&
        doc['life-span']['begin']['\$t'] != null) {
      begin = doc['life-span']['begin']['\$t'].toString();
    }
    return Influence(
        name: doc['name']['\$t'].toString(), country: country, date: begin);
  }
}
