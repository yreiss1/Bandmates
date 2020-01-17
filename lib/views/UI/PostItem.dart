import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/CommentsScreen.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
import '../ProfileScreen.dart';
import '../../models/Post.dart';
import 'package:provider/provider.dart';
import '../../models/User.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final User currentUser;

  PostItem({this.post, this.currentUser});

  int _likeCount = 0;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPostHeader(context),
        if (post.mediaUrl != null) buildPostImage(context),
        buildPostFooter(context),
      ],
    );
  }

  buildPostHeader(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: post.avatar != null
            ? CachedNetworkImageProvider(post.avatar)
            : AssetImage('assets/images/user-placeholder.png'),
        backgroundColor: Colors.grey,
      ),
      title: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName,
            arguments: ProfileScreenArguments(userId: post.ownerId)),
        child: Text(
          post.username,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: post.ownerId == prefix0.currentUser.uid
          ? IconButton(
              onPressed: () => _handleDeletePost(context),
              icon: Icon(LineIcons.ellipsis_h),
            )
          : IconButton(
              onPressed: () {},
              icon: Icon(LineIcons.angle_up),
            ),
    );
  }

  _handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<PostProvider>(context)
                      .deletePost(ownderId: post.ownerId, postId: post.postId);
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildPostImage(BuildContext context) {
    return GestureDetector(
        onDoubleTap: () => post.toggleLikePost(context),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            customNetworkImage(post.mediaUrl),
            /*
            Animator(
              duration: Duration(milliseconds: 300),
              tween: Tween(begin: 0.8, end: 1.4),
              curve: Curves.elasticOut,
              cycles: 0,
              builder: (anim) => Transform.scale(
                scale: anim.value,
                child: Icon(Icons.favorite),
              ),
            )
            */
          ],
        ));
  }

  buildPostFooter(context) {
    final post = Provider.of<Post>(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            Consumer<Post>(
              builder: (ctx, post, child) => Container(
                  width: 70,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(post.likes[currentUser.uid] == null ||
                                post.likes[currentUser.uid] == false
                            ? Icons.favorite_border
                            : Icons.favorite),
                        onPressed: () {
                          post.toggleLikePost(context);
                        },
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(post.likes.values.length.toString()),
                    ],
                  )),
            ),
            /*
            GestureDetector(
              onTap: () => post.toggleLikePost(currentUserId),
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.red,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(getLikeCount().toString()),
            */
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(
                  context: context,
                  postId: post.postId,
                  ownerId: post.ownerId,
                  mediaUrl: post.mediaUrl),
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

  showComments({context, String postId, String ownerId, String mediaUrl}) {
    User currentUser = Provider.of<UserProvider>(context).user;
    Navigator.push(context, MaterialPageRoute(builder: (
      ctx,
    ) {
      return CommentsScreen(
        postId: postId,
        postOwnerId: ownerId,
        postMediaUrl: mediaUrl,
        currentUser: currentUser,
      );
    }));
  }
}
