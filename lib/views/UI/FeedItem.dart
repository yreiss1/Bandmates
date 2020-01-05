import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/PostScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../../models/User.dart';
import '../../models/Follow.dart';

class FeedItem extends StatefulWidget {
  final String username;
  final String userId;
  final int type;
  final String mediaUrl;
  final String postId;
  final String avatar;
  final String text;
  final DateTime time;

  FeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.avatar,
      this.text,
      this.time});

  factory FeedItem.fromDocument(DocumentSnapshot doc) {
    return FeedItem(
      username: doc['user'],
      userId: doc['userId'],
      avatar: doc['avatar'],
      type: doc['type'],
      postId: doc['postId'],
      text: doc['text'],
      time: doc['time'].toDate(),
      mediaUrl: doc['mediaUrl'],
    );
  }

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  Widget mediaPreview;

  bool _isFollowing;
  String activityItemText;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  _checkIfFollowing() async {
    await Firestore.instance
        .collection("following")
        .document(currentUser.uid)
        .collection("following")
        .document(widget.userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          this._isFollowing = true;
        });
      } else {
        setState(() {
          this._isFollowing = false;
        });
      }
    });
  }

  showPost(context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: this.widget.postId,
                  userId: uid,
                )));
  }

  showProfile(context) async {
    User user = await Provider.of<UserProvider>(context).getUser(widget.userId);
    Navigator.pushNamed(context, ProfileScreen.routeName,
        arguments: ProfileScreenArguments(userId: user.uid));
  }

  configureMediaPreview(context) {
    // 0: Like, 1: Comment, 2: Follow
    if (widget.type == 0 || widget.type == 1) {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Container(
            height: 50,
            width: 50,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.mediaUrl == null
                            ? CachedNetworkImageProvider(
                                "https://www.whittierfirstday.org/wp-content/uploads/default-user-image-e1501670968910.png")
                            : CachedNetworkImageProvider(widget.mediaUrl))),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = _isFollowing == true
          ? FlatButton.icon(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              color: Color(0xff829abe),
              icon: Icon(LineIcons.user_plus),
              textColor: Colors.white,
              label: Text("Unfollow"),
              onPressed: () {
                Provider.of<FollowProvider>(context).unfollowUser(
                    currentUserId: currentUser.uid, usersId: widget.userId);
                setState(() {
                  _isFollowing = false;
                });
              })
          : FlatButton.icon(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              color: Theme.of(context).primaryColor,
              icon: Icon(LineIcons.user_plus),
              textColor: Colors.white,
              label: Text("Follow"),
              onPressed: () {
                Provider.of<FollowProvider>(context).followUser(
                    currentUserId: currentUser.uid, usersId: widget.userId);
                setState(() {
                  _isFollowing = true;
                });
              });
    }

    if (widget.type == 0) {
      activityItemText = "liked your post";
    } else if (widget.type == 2) {
      activityItemText = "is following you";
    } else if (widget.type == 1) {
      activityItemText = "replied: ${widget.text}";
    } else {
      activityItemText = "Error: unkown type: '${widget.type}'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          //color: Colors.white54,
          child: ListTile(
            title: GestureDetector(
              onTap: () => showProfile(context),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text: widget.username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $activityItemText')
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: widget.avatar != null
                  ? CachedNetworkImageProvider(widget.avatar)
                  : CachedNetworkImageProvider(
                      "https://www.whittierfirstday.org/wp-content/uploads/default-user-image-e1501670968910.png"),
            ),
            subtitle: Text(
              timeago.format(widget.time),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: mediaPreview,
          ),
        ));
  }
}
