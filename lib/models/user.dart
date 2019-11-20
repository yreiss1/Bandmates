import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
        'location': this.location == null ? null : this.location.data,
        'photoUrl': this.photoUrl
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
    print("In getUser");
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
