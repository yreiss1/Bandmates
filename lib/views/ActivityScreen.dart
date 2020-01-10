import 'package:flutter/material.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
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

    return ListView(
      children: <Widget>[buildSearchHeader(context), buildMainArea(context)],
    );
  }

  buildMainArea(context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Container(
          child: FutureBuilder<List<FeedItem>>(
        future: getActivityFeed(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }

          return ListView(children: snapshot.data);
        },
      )),
    );
  }

  buildSearchHeader(context) {
    return Container(
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: 100,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Activity Feed",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              IconButton(
                icon: Icon(
                  LineIcons.search,
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}
