import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { Concert, Audition, JamSession }

//0: Concert, 1: Audition, 2: JamSession
class Event {
  final String ownerId;
  final String eventId;
  final String name;
  final DateTime time;
  final GeoFirePoint location;
  final String text;
  final int type;
  final String title;
  final String photoUrl;
  final Map<dynamic, dynamic> audition;
  final Map<dynamic, dynamic> attending;

  Event(
      {this.time,
      this.title,
      this.text,
      this.location,
      this.type,
      this.audition,
      this.ownerId,
      this.eventId,
      this.name,
      this.attending,
      this.photoUrl});

  factory Event.fromDocument(DocumentSnapshot doc) {
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

    return Event(
        location: loc,
        name: doc.data['user'],
        title: doc.data['title'],
        text: doc.data['text'],
        type: doc.data['type'],
        time: doc.data['time'].toDate(),
        eventId: doc.documentID,
        audition: doc.data['audition'],
        ownerId: doc.data['ownerId'],
        attending: doc.data['attending'],
        photoUrl: doc.data['photoUrl']);
  }
}

class EventProvider with ChangeNotifier {
  CollectionReference eventsRef = Firestore.instance.collection("events");
  StorageReference storageRef = FirebaseStorage.instance.ref();

  List<Event> _events = [];

  List<Event> get events {
    return [..._events];
  }

  Future<void> uploadEvent(Event event) async {
    eventsRef.document(event.eventId).setData({
      "ownerId": event.ownerId,
      "user": event.name,
      "title": event.title,
      "type": event.type,
      "text": event.text,
      "loc": event.location == null ? null : event.location.data,
      "time": event.time,
      "audtion": event.audition,
      "photoUrl": event.photoUrl,
      "attending": {}
    });

    _events.insert(0, event);
    notifyListeners();
  }

  Future<String> uploadEventImage(
      File imageFile, String ownerId, String eventId) async {
    String downloadUrl;
    StorageUploadTask uploadTask = storageRef
        .child("eventPhotos")
        .child(ownerId)
        .child("$eventId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }
}
