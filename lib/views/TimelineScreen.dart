import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/models/Post.dart';
import 'package:jammerz/models/ProfileScreenArguments.dart';
import 'package:jammerz/views/HomeScreen.dart' as prefix0;
import 'package:jammerz/views/ProfileScreen.dart';
import 'package:jammerz/views/UI/PostItem.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/User.dart';

final usersRef = Firestore.instance.collection('users');

class TimelineScreen extends StatefulWidget {
  final User currentUser;

  TimelineScreen({this.currentUser});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Post> _posts = [];
  List<String> _followingList = [];

  @override
  void initState() {
    super.initState();

    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("timeline")
        .document(widget.currentUser.uid)
        .collection("timelinePosts")
        .orderBy('time', descending: true)
        .getDocuments();

    List<Post> posts = snapshot.documents
        .map(
          (doc) => Post.fromDocument(doc),
        )
        .toList();

    setState(() {
      this._posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("following")
        .document(widget.currentUser.uid)
        .collection("following")
        .getDocuments();

    setState(() {
      _followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          //.orderBy("time")
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }

        List<User> usersToFollow = [];

        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);

          final bool isAuthUser = widget.currentUser.uid == user.uid;
          final bool isFollowingUser = _followingList.contains(user.uid);

          if (isAuthUser || isFollowingUser) {
            return;
          } else {
            usersToFollow.add(user);
          }
        });

        return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      LineIcons.user_plus,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 0.0,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: usersToFollow.length,
                  itemBuilder: (context, index) {
                    User user = usersToFollow[index];
                    return ListTile(
                      onTap: () => Navigator.pushNamed(
                          context, ProfileScreen.routeName,
                          arguments: ProfileScreenArguments(userId: user.uid)),
                      title: Text(user.name),
                      subtitle: Text(buildSubtitle(user.instruments) +
                          "\n" +
                          user.location
                              .distance(
                                  lat: widget.currentUser.location.latitude,
                                  lng: widget.currentUser.location.longitude)
                              .round()
                              .toString() +
                          " kilometers away"),
                      isThreeLine: true,
                      enabled: true,
                      leading: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: user.photoUrl == null
                              ? AssetImage('assets/images/user-placeholder.png')
                              : NetworkImage(user.photoUrl),
                        ),
                        decoration: new BoxDecoration(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String buildSubtitle(Map<dynamic, dynamic> map) {
    List l = map.keys.toList();

    String result = l.fold(
        "",
        (inc, ins) =>
            inc +
            " " +
            ins.toString()[0].toUpperCase() +
            ins.toString().substring(1) +
            " " +
            "\\");

    result = result.substring(1, result.length - 1);
    if (result.length > 40) {
      result = result.substring(0, 40);
      result += "...";
    }
    return result;
  }

  buildTimeline() {
    if (_posts == null) {
      return circularProgress(context);
    } else if (_posts.isEmpty) {
      return buildUsersToFollow();
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value: _posts[index],
          child: PostItem(
            currentUser: prefix0.currentUser,
            post: _posts[index],
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        thickness: 10,
      ),
      itemCount: _posts.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("[Timeline] Rebuilding the widget");

    return RefreshIndicator(
      onRefresh: () => getTimeline(),
      child: buildTimeline(),
    );
  }
}
