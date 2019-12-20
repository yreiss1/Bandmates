import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment extends StatelessWidget {
  final String user;
  final String uid;
  final String avatar;
  final String text;
  final DateTime time;

  Comment({this.user, this.uid, this.avatar, this.text, this.time});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        user: doc['user'],
        uid: doc['uid'],
        text: doc['text'],
        avatar: doc['avatar'],
        time: doc['time'].toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(text),
          leading: CircleAvatar(
            backgroundImage: avatar != null
                ? CachedNetworkImageProvider(avatar)
                : AssetImage("assets/images/user-placeholder.png"),
          ),
          subtitle: Text(timeago.format(time)),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}
