import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:jammerz/models/ProfileScreenArguments.dart';
import '../ProfileScreen.dart';
import '../../models/Post.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:provider/provider.dart';
import '../../models/User.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final User user;

  PostItem({this.post, this.user});

  int getLikeCount() {
    if (this.post.likes == null) {
      return 0;
    }

    return post.likes.values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPostHeader(context),
        Divider(
          height: 0.0,
        ),
        if (post.mediaUrl != null) buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  buildPostHeader(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? CachedNetworkImageProvider(user.photoUrl)
            : AssetImage('assets/images/user-placeholder.png'),
        backgroundColor: Colors.grey,
      ),
      title: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName,
            arguments: ProfileScreenArguments(user: user)),
        child: Text(
          user.name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: post.location != null ? Text(post.location) : Container(),
      trailing: IconButton(
        onPressed: () => print("Deleting post"),
        icon: Icon(LineIcons.ellipsis_h),
      ),
    );
  }

  buildPostImage() {
    return GestureDetector(
        onDoubleTap: () => print("Liking post"),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[Image.network(post.mediaUrl)],
        ));
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => print("Liking post"),
              child: Icon(
                LineIcons.heart,
                size: 28.0,
                color: Colors.red,
              ),
            ),
            Text(getLikeCount().toString()),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => print("Show Comments"),
              child: Icon(
                LineIcons.comment,
                size: 28.0,
              ),
            ),
          ],
        ),
        if (post.text != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(post.text),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            Text(
              DateFormat.yMMMMEEEEd().format(post.time),
            )
          ],
        ),
      ],
    );
  }
}
