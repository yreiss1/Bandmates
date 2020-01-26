import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/ChatRoomScreen.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:line_icons/line_icons.dart';

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
      userId: doc.documentID,
      username: doc['name'],
      avatar: doc['avatar'],
      location: loc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 0,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName,
              arguments: ProfileScreenArguments(userId: userId)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: avatar != null
                  ? CachedNetworkImageProvider(avatar)
                  : AssetImage("assets/images/user-placeholder.png"),
            ),
            title: Text(
              username,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              currentUser.location
                      .distance(lat: location.latitude, lng: location.longitude)
                      .round()
                      .toString() +
                  " km away from you",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        )
      ],
    );
  }
}
