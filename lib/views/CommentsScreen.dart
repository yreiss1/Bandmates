import 'package:flutter/material.dart';
import 'package:bandmates/views/UI/Header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import '../models/User.dart';
import '../models/Comment.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final User currentUser;

  TextEditingController _textEditingController = new TextEditingController();
  CommentsScreen(
      {this.postId, this.postOwnerId, this.postMediaUrl, this.currentUser});

  buildComments() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("comments")
          .document(postId)
          .collection("comments")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<Comment> comments = [];

        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });

        return ListView(children: comments);
      },
    );
  }

  addComment() {
    print("[CommentsScreen] PostId: " + postId.toString());
    Firestore.instance
        .collection("comments")
        .document(postId)
        .collection("comments")
        .add({
      "user": currentUser.name,
      "text": _textEditingController.text,
      "time": DateTime.now(),
      "avatar": currentUser.photoUrl,
      "uid": currentUser.uid
    });

    if (currentUser.uid != postOwnerId) {
      Firestore.instance
          .collection("feed")
          .document(postOwnerId)
          .collection("feedItems")
          .add({
        "type": 1,
        "text": _textEditingController.text,
        "user": currentUser.name,
        "userId": currentUser.uid,
        "avatar": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "time": DateTime.now()
      });
    }

    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Comments",
          style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            LineIcons.arrow_left,
            color: Color(0xFF1d1e2c),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
              title: TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(labelText: "Write a comment"),
              ),
              trailing: IconButton(
                icon: Icon(Icons.send),
                color: Theme.of(context).primaryColor,
                onPressed: () => addComment(),
              ))
        ],
      ),
    );
  }
}
