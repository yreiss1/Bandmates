import 'package:flutter/material.dart';
import 'package:jammerz/views/UI/Progress.dart';
import '../models/User.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './UI/FeedItem.dart';

class ActivityScreen extends StatelessWidget {
  Future<List<FeedItem>> getActivityFeed(BuildContext context) async {
    //print("[ActivityScreen]: in getActivityFeed function");
    User currentUser = Provider.of<UserProvider>(context).user;
    QuerySnapshot snapshot = await Firestore.instance
        .collection("feed")
        .document(currentUser.uid)
        .collection("feedItems")
        .orderBy("time", descending: true)
        .limit(50)
        .getDocuments();

    List<FeedItem> feedItems = [];

    snapshot.documents.forEach((item) {
      feedItems.add(FeedItem.fromDocument(item));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    print("[ActivityScreen] Rebuilding Widget");
    return Scaffold(
        body: Container(
      child: FutureBuilder<List<FeedItem>>(
        future: getActivityFeed(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }

          return ListView(children: snapshot.data);
        },
      ),
    ));
  }
}
