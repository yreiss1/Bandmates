import 'dart:io';

import 'package:bandmates/models/Post.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/PostScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/User.dart';
import '../../models/Follow.dart';

class FeedItem extends StatefulWidget {
  final String username;
  final String userId;
  final int type;
  final String mediaUrl;
  final String postId;
  final int postType;
  final String avatar;
  final String text;
  final DateTime time;

  FeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.postType,
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
      postType: doc['postType'],
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

  String activityItemText;
  String _tempDir;

  @override
  void initState() {
    super.initState();
    getTemporaryDirectory().then((d) => _tempDir = d.path);
  }

  showPost(context) async {
    Post post = await Provider.of<PostProvider>(context)
        .getPost(postId: widget.postId, userId: currentUser.uid);
    print("[FeedItem] post: " + post.title);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          post: post,
        ),
      ),
    );
  }

  showProfile(context) async {
    User user = await Provider.of<UserProvider>(context).getUser(widget.userId);
    Navigator.pushNamed(context, ProfileScreen.routeName,
        arguments: ProfileScreenArguments(userId: user.uid));
  }

  configureMediaPreview(context) {
    // 0: Like, 1: Comment, 2 Attending
    if (widget.postType == 0) {
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
    } else if (widget.postType == 1) {
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
                            : AssetImage(
                                "assets/images/audio-placeholder.png"))),
              ),
            ),
          ),
        ),
      );
    } else if (widget.postType == 2) {
      mediaPreview = FutureBuilder(
        future: VideoThumbnail.thumbnailFile(
          video: widget.mediaUrl,
          thumbnailPath: _tempDir,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 100,
          maxWidth: 100,
          quality: 75,
        ),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }

          if (snapshot.hasError) {
            return Container();
          }

          return GestureDetector(
            onTap: () => showPost(context),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                        image: FileImage(
                          File(snapshot.data),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (widget.type == 0) {
      activityItemText = "liked your post";
    } else if (widget.type == 1) {
      activityItemText = "replied: ${widget.text}";
    } else if (widget.type == 2) {
      activityItemText = "is attending your event ${widget.text}";
    } else {
      activityItemText = "Error: unkown type: '${widget.type}'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            title: GestureDetector(
              onTap: () => showProfile(context),
              child: RichText(
                textWidthBasis: TextWidthBasis.parent,
                text:
                    TextSpan(style: TextStyle(color: Colors.black), children: [
                  TextSpan(
                    text: widget.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $activityItemText')
                ]),
              ),
            ),
            leading: CircleAvatar(
              radius: 26,
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
        ),
        Divider(),
      ],
    );
  }
}
