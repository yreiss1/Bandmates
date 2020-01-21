import 'package:bandmates/models/Instrument.dart';
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
      @required this.bio,
      @required this.influences,
      @required this.location,
      @required this.genres,
      @required this.instruments,
      this.time,
      @required this.photoUrl});

  final String uid;
  final DateTime time;
  final String name;
  final String bio;
  GeoFirePoint location;
  final Map<dynamic, dynamic> genres;
  final Map<dynamic, dynamic> instruments;
  final List<dynamic> influences;
  final String photoUrl;

  // Clips

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'bio': this.bio,
        'genres': this.genres,
        'instruments': this.instruments,
        'influences': this.influences,
        'location': this.location == null ? null : location.data,
        'photoUrl': this.photoUrl,
        'time': DateTime.now(),
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    if (doc.data == null) {
      return null;
    }
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
      name: doc.data['name'],
      photoUrl: doc.data['photoUrl'],
      bio: doc.data['bio'],
      genres: doc.data['genres'],
      instruments: doc.data['instruments'],
      influences: doc.data['influences'],
      location: loc,
      time: doc.data['time'] == null ? null : doc.data['time'].toDate(),
    );
  }
}

class UserProvider with ChangeNotifier {
  final Geoflutterfire geo = Geoflutterfire();

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

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return userRef.document(uid).snapshots();
  }

  Future<void> uploadUser(String uid, User userIn) async {
    currentUser = userIn;
    //print("[UserProvider] userIn: " + userIn.toJson().toString());
    await userRef.document(uid).setData({
      'name': userIn.name,
      'bio': userIn.bio,
      'genres': userIn.genres,
      'instruments': userIn.instruments,
      'influences': userIn.influences,
      'photoUrl': userIn.photoUrl,
      'time': DateTime.now(),
      'location': userIn.location.data,
    });
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

  Stream<List<DocumentSnapshot>> getClosest(GeoFirePoint center) {
    return geo.collection(collectionRef: userRef).within(
        center: center, radius: 100, field: 'location', strictMode: true);
  }
}
