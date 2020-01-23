import 'package:bandmates/views/HomeScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Attending extends StatelessWidget {
  final String userId;
  final String username;
  final String avatar;
  final GeoFirePoint location;

  Attending({this.userId, this.username, this.avatar, this.location});

  factory Attending.fromDocument(DocumentSnapshot doc) {
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
    return Attending(
      userId: doc['userId'],
      username: doc['name'],
      avatar: doc['avatar'],
      location: doc['loc'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 0,
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: avatar != null
                ? CachedNetworkImageProvider(avatar)
                : AssetImage("assets/images/user-placeholder.png"),
          ),
          title: Text(username),
          subtitle: Text(currentUser.location
                  .distance(lat: location.latitude, lng: location.longitude)
                  .round()
                  .toString() +
              " km away"),
        )
      ],
    );
  }
}
