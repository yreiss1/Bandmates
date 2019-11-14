import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class User {
  User(
      {@required this.uid,
      @required this.name,
      @required this.email,
      @required this.birthday,
      @required this.gender,
      @required this.bio,
      @required this.practiceSpace,
      @required this.transportation,
      this.location,
      this.followers = 0,
      this.genres,
      this.instruments,
      this.created,
      this.photoUrl});

  final String uid;
  final DateTime created;
  final String name;
  final String email;
  final DateTime birthday;
  final String gender;
  final String bio;
  final bool transportation;
  final GeoFirePoint location;
  int followers;
  final Map<dynamic, dynamic> genres;
  final Map<dynamic, dynamic> instruments;
  final String photoUrl;

  // Clips

  final bool practiceSpace;

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'age':
            this.birthday == null ? null : this.birthday.millisecondsSinceEpoch,
        'bio': this.bio,
        'gender': this.gender,
        'transport': this.transportation,
        'practice': this.practiceSpace,
        'followers': this.followers,
        'genres': this.genres,
        'instruments': this.instruments,
        'location': this.location.data,
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint loc;
    if (doc.data['location'] != null) {
      GeoPoint point = doc.data['location']['geopoint'];

      loc = point == null
          ? null
          : geo.point(latitude: point.latitude, longitude: point.longitude);
    } else {
      loc = null;
    }

    return User(
        uid: doc.data['id'],
        email: doc.data['email'],
        name: doc.data['name'],
        photoUrl: doc.data['photoUrl'],
        birthday: doc.data['birthday'],
        gender: doc.data['gender'],
        bio: doc.data['bio'],
        genres: doc.data['genres'],
        instruments: doc.data['instruments'],
        practiceSpace: doc.data['practice'],
        transportation: doc.data['transport'],
        location: loc);
  }
}

class UserProvider with ChangeNotifier {}
