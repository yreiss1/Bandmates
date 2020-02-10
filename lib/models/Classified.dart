import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

enum ClassifiedType { Selling, Buying, Looking }

class Classified {
  final String ownerId;
  final String classifiedId;
  final String username;
  final String title;
  final String text;
  final GeoFirePoint location;
  final String photoUrl;
  final int type;

  Classified(
      {this.ownerId,
      this.classifiedId,
      this.location,
      this.title,
      this.text,
      this.photoUrl,
      this.username,
      this.type});

  factory Classified.fromDocument(DocumentSnapshot doc) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint loc;

    if (doc.data['loc'] != null) {
      GeoPoint point = doc.data['loc']['geopoint'];

      loc = point == null
          ? null
          : geo.point(latitude: point.latitude, longitude: point.longitude);
    } else {
      loc = null;
    }

    return Classified(
        location: loc,
        classifiedId: doc.data['clasId'],
        ownerId: doc.data['ownerId'],
        username: doc.data['username'],
        title: doc.data['title'],
        text: doc.data['text'],
        photoUrl: doc.data['photoUrl']);
  }
}

class ClassifiedProvider with ChangeNotifier {
  CollectionReference classRef = Firestore.instance.collection("classified");
  StorageReference storageRef = FirebaseStorage.instance.ref();
  final Geoflutterfire geo = Geoflutterfire();

  Future<void> uploadClassified(Classified classified) async {
    classRef.document(classified.classifiedId).setData({
      'ownerId': classified.ownerId,
      'username': classified.username,
      'title': classified.title,
      'text': classified.text,
      'type': classified.type,
      'loc': classified.location,
      'photoUrl': classified.photoUrl
    });
  }

  Future<String> uploadEventImage(
      File imageFile, String ownerId, String classifiedId) async {
    String downloadUrl;
    StorageUploadTask uploadTask = storageRef
        .child("classifiedPhotos")
        .child(ownerId)
        .child("$classifiedId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  Stream<List<DocumentSnapshot>> getClosest(
      GeoFirePoint center, int radius, int type) {
    return geo
        .collection(
            collectionRef: type == null
                ? classRef
                : classRef.where('type', isEqualTo: type))
        .within(
            center: center,
            radius: radius.toDouble(),
            field: 'loc',
            strictMode: true);
  }
}
