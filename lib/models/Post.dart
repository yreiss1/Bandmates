import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Post {
  final String text;
  final String ownerId;
  final String postId;
  final String username;
  final Map likes;
  final DateTime time;
  final String mediaUrl;
  final String location;

  Post(
      {@required this.text,
      @required this.time,
      this.mediaUrl,
      this.location,
      this.likes,
      this.ownerId,
      this.postId,
      this.username});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.data['postId'],
      ownerId: doc.data['ownerId'],
      username: doc.data['user'],
      text: doc.data['text'],
      mediaUrl: doc.data['media'],
      likes: doc.data['likes'],
      location: doc.data['loc'],
      time: doc.data['time'].toDate(),
    );
  }
}

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts {
    return [..._posts];
  }

  StorageReference storageRef = FirebaseStorage.instance.ref();

  CollectionReference postRef = Firestore.instance.collection("posts");

  Future<String> uploadMedia(File file, String postId) async {
    String downloadUrl;
    if (file != null) {
      StorageUploadTask uploadTask =
          storageRef.child("post_$postId.jpg").putFile(file);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      downloadUrl = await storageSnap.ref.getDownloadURL();
    }

    return downloadUrl;
  }

  Future<void> uploadPost(
      Post post, String uid, String name, String postId) async {
    postRef.document(uid).collection("userPosts").document(postId).setData({
      "postId": post.postId,
      "ownerId": uid,
      "user": name,
      "media": post.mediaUrl,
      "text": post.text,
      "loc": post.location,
      "time": post.time,
      "likes": {}
    });
  }

  Future<List<Post>> getUsersPosts(String uid) async {
    List<Post> results = [];
    QuerySnapshot querySnap = await postRef
        .document(uid)
        .collection("userPosts")
        .orderBy("time", descending: true)
        .getDocuments();

    List<DocumentSnapshot> snaps = querySnap.documents;
    snaps.forEach((snapshot) {
      //print("[PostProvider] snapshotData: " + snapshot.data.toString());
      results.add(Post.fromDocument(snapshot));
    });

    return results;
  }
}
