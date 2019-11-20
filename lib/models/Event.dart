import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { Concert, Audition, JamSession }

class Event {
  final DateTime time;
  final GeoFirePoint location;
  final String text;
  final int type;
  final Map<dynamic, dynamic> audition;

  Event({this.time, this.text, this.location, this.type, this.audition});
}

class EventProvider with ChangeNotifier {
  CollectionReference eventsRef = Firestore.instance.collection("events");
  List<Event> _events = [];

  List<Event> get events {
    return [..._events];
  }

  Future<void> uploadEvent(
      Event event, String eventId, String uid, String name) async {
    eventsRef.document(uid).collection("userEvents").document(eventId).setData({
      "eventId": eventId,
      "ownerId": uid,
      "user": name,
      "text": event.text,
      "loc": event.location.data,
      "time": event.time,
      "audtion": event.audition,
      "likes": {}
    });

    _events.insert(0, event);
    notifyListeners();
  }
}
