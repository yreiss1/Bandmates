import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:geoflutterfire/geoflutterfire.dart';

class Post {
  final String text;
  final DateTime time;
  final File file;
  final String location;

  Post({@required this.text, @required this.time, this.file, this.location});
}

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts {
    return [..._posts];
  }

  StorageReference storageRef = FirebaseStorage.instance.ref();

  CollectionReference postRef = Firestore.instance.collection("posts");

  Future<void> uploadPost(
      Post post, String postId, String uid, String name) async {
    String downloadUrl;
    if (post.file != null) {
      StorageUploadTask uploadTask =
          storageRef.child("post_$postId.jpg").putFile(post.file);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      downloadUrl = await storageSnap.ref.getDownloadURL();
    }

    postRef.document(uid).collection("userPosts").document(postId).setData({
      "postId": postId,
      "ownerId": uid,
      "user": name,
      "media": downloadUrl,
      "text": post.text,
      "loc": post.location,
      "time": post.time,
      "likes": {}
    });
  }

  Future<List<Post>> getUsersPosts(String uid) async {
    List<Post> results = [];
    QuerySnapshot querySnap =
        await postRef.document(uid).collection("userPosts").getDocuments();

    List<DocumentSnapshot> snaps = querySnap.documents;
    snaps.forEach((snapshot) {
      /*
      Geoflutterfire geo = Geoflutterfire();
      GeoFirePoint loc;
      if (snapshot.data['loc'] != null) {
        GeoPoint point = snapshot.data['loc']['geopoint'];

        loc = point == null
            ? null
            : geo.point(latitude: point.latitude, longitude: point.longitude);
      } else {
        loc = null;
      }
      */

      print("[PostProvider] snapshotData: " + snapshot.data.toString());
      results.add(Post(
        text: snapshot.data['text'],
        time: snapshot.data['time'].toDate(),
        location: snapshot.data['loc'],
      ));
    });

    return results;
  }
}
