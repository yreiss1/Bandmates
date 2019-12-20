import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class User {
  User(
      {@required this.uid,
      @required this.name,
      @required this.email,
      @required this.bio,
      @required this.practiceSpace,
      @required this.transportation,
      this.location,
      this.genres,
      this.instruments,
      this.time,
      this.photoUrl});

  final String uid;
  final DateTime time;
  final String name;
  final String email;
  final String bio;
  final bool transportation;
  final GeoFirePoint location;
  final Map<dynamic, dynamic> genres;
  final Map<dynamic, dynamic> instruments;
  final String photoUrl;

  // Clips

  final bool practiceSpace;

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'bio': this.bio,
        'transport': this.transportation,
        'practice': this.practiceSpace,
        'genres': this.genres,
        'instruments': this.instruments,
        'location': this.location == null ? null : this.location.data,
        'photoUrl': this.photoUrl,
        'time': DateTime.now(),
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
      uid: doc.documentID,
      email: doc.data['email'],
      name: doc.data['name'],
      photoUrl: doc.data['photoUrl'],
      bio: doc.data['bio'],
      genres: doc.data['genres'],
      instruments: doc.data['instruments'],
      practiceSpace: doc.data['practice'],
      transportation: doc.data['transport'],
      location: loc,
      time: doc.data['time'],
    );
  }
}

class UserProvider with ChangeNotifier {
  User currentUser;

  User get user {
    return currentUser;
  }

  Location location = new Location();
  LocationData userLocation;
  CollectionReference userRef = Firestore.instance.collection("users");
  StorageReference storageRef = FirebaseStorage.instance.ref();

  Future<User> getUser(String uid) async {
    print("[User] In getUser");
    DocumentSnapshot userSnap = await userRef.document(uid).get();
    if (userSnap.data == null) {
      return null;
    }
    User user = User.fromDocument(userSnap);
    return user;
  }

  void setCurrentUser(User user) {
    currentUser = user;
  }

  Future<DocumentSnapshot> getSnapshot(String uid) async {
    print("In getSnapshot");
    return await userRef.document(uid).get();
  }

  Future<void> uploadUser(String uid, User userIn) async {
    print("In uploadUser" + userIn.instruments.toString());

    currentUser = userIn;
    await Firestore.instance
        .collection("users")
        .document(uid)
        .setData(userIn.toJson());

    await Firestore.instance
        .collection("followers")
        .document(uid)
        .collection("followers")
        .document(uid)
        .setData({});
  }

  Future<String> uploadProfileImage(File imageFile, String uid) async {
    String downloadUrl;
    StorageUploadTask uploadTask =
        storageRef.child("profilePhotos").child("$uid.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  LocationData getUserLocation() {
    return userLocation;
  }

  Future<void> obtainLocation() async {
    var pos = await location.getLocation();
    userLocation = pos;
  }
}
