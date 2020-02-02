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
  final DateTime start;
  final DateTime end;
  final GeoFirePoint location;
  final String text;
  final int type;
  final String title;
  final String photoUrl;
  final List<dynamic> genres;
  final List<dynamic> audition;
  final Map<dynamic, dynamic> attending;

  Event(
      {this.start,
      this.end,
      this.title,
      this.text,
      this.location,
      this.type,
      this.audition,
      this.ownerId,
      this.eventId,
      this.genres,
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
        genres: doc.data['genres'],
        start: doc.data['start'].toDate(),
        end: doc.data['end'] != null ? doc.data['end'].toDate() : null,
        eventId: doc.documentID,
        audition: doc.data['audition'],
        ownerId: doc.data['ownerId'],
        attending: doc.data['attending'],
        photoUrl: doc.data['photoUrl']);
  }
}

class EventProvider with ChangeNotifier {
  CollectionReference eventsRef = Firestore.instance.collection("events");
  CollectionReference attendingRef = Firestore.instance.collection('attending');
  StorageReference storageRef = FirebaseStorage.instance.ref();
  final Geoflutterfire geo = Geoflutterfire();

  List<Event> _events = [];

  List<Event> get events {
    return [..._events];
  }

  Future<void> uploadEvent(Event event) async {
    eventsRef.document(event.eventId).setData({
      "ownerId": event.ownerId,
      "user": event.name,
      "title": event.title,
      "genres": event.genres,
      "type": event.type,
      "text": event.text,
      "loc": event.location == null ? null : event.location.data,
      "start": event.start,
      "end": event.end,
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

  Stream<List<DocumentSnapshot>> getClosest(
      GeoFirePoint center, int radius, int type) {
    return geo
        .collection(
            collectionRef: type == null
                ? eventsRef
                : eventsRef.where('type', isEqualTo: type))
        .within(
            center: center,
            radius: radius.toDouble(),
            field: 'loc',
            strictMode: true);
  }

  Stream<QuerySnapshot> getAttending(String eventId) {
    return attendingRef.document(eventId).collection("attending").snapshots();
  }

  Future<void> attendEvent(
      String eventId,
      String eventTitle,
      String userId,
      String username,
      GeoFirePoint location,
      String avatar,
      String ownerId,
      String mediaUrl) async {
    WriteBatch batch = Firestore.instance.batch();

    batch.setData(
        attendingRef.document(eventId).collection("attending").document(userId),
        {'name': username, 'avatar': avatar, 'loc': location.data});

    batch.setData(
        Firestore.instance
            .collection("feed")
            .document(ownerId)
            .collection('feedItems')
            .document(),
        {
          'avatar': avatar,
          'type': 2,
          'time': DateTime.now(),
          'user': username,
          'userId': userId,
          'eventId': eventId,
          'text': eventTitle,
          'mediaUrl': mediaUrl
        });

    batch.commit().catchError((error) => print(error.toString()));
  }
}
