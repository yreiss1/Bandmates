import 'package:flutter/widgets.dart';

import 'package:meta/meta.dart';

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User with GenresMixin, InstrumentsMixin {
  User(
      {@required this.uid,
      @required this.name,
      @required this.email,
      @required this.birthday,
      @required this.gender,
      @required this.bio,
      @required this.practiceSpace,
      @required this.transportation,
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
  int followers;
  final List<dynamic> genres;
  final List<dynamic> instruments;
  final String photoUrl;


  // Clips

  final bool practiceSpace;
  final Position location = null;

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
        'genres': this.genres.toList(),
        'instruments': this.instruments.toList()
      };

  factory User.fromDocument(DocumentSnapshot doc) {
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
      transportation: doc.data['transportation'],
    );
  }
}

class UserProvider with ChangeNotifier {}
