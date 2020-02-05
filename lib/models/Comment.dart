import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import './User.dart';

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

  showProfile(context) async {
    User user = await Provider.of<UserProvider>(context).getUser(uid);
    Navigator.pushNamed(context, ProfileScreen.routeName,
        arguments: ProfileScreenArguments(userId: user.uid));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 0,
        ),
        ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context),
            child: RichText(
              textWidthBasis: TextWidthBasis.parent,
              text: TextSpan(style: TextStyle(color: Colors.black), children: [
                TextSpan(
                  text: user,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' $text')
              ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: avatar != null
                ? CachedNetworkImageProvider(avatar)
                : AssetImage("assets/images/user-placeholder.png"),
          ),
          subtitle: Text(timeago.format(time)),
        ),
      ],
    );
  }
}
