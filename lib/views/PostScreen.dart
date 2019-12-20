import 'package:flutter/material.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/UI/Header.dart';
import 'package:bandmates/views/UI/PostItem.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:provider/provider.dart';
import '../models/Post.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: Provider.of<PostProvider>(context)
          .getPost(userId: userId, postId: postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }

        return Scaffold(
          appBar: header(snapshot.data.text, context),
          body: ListView(
            children: <Widget>[
              Container(
                  child: ChangeNotifierProvider.value(
                      value: snapshot.data,
                      child: PostItem(
                        currentUser: Provider.of<UserProvider>(context).user,
                        post: snapshot.data,
                      ))),
            ],
          ),
        );
      },
    );
  }
}
