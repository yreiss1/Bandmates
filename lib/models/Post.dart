import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import './User.dart';

class Post with ChangeNotifier {
  final String text;
  final String ownerId;
  final String postId;
  final String username;
  final Map likes;
  final DateTime time;
  final String mediaUrl;
  final String location;
  final String avatar;

  Post(
      {@required this.text,
      @required this.time,
      this.mediaUrl,
      this.location,
      this.likes,
      this.ownerId,
      this.postId,
      this.username,
      this.avatar});

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

  void toggleLikePost(context) async {
    User user = Provider.of<UserProvider>(context).user;
    String uid = user.uid;
    if (likes[uid] == null || likes[uid] == false) {
      likes[uid] = true;
      notifyListeners();
      print("OwnerId: " + ownerId + " postId: " + postId);
      Firestore.instance
          .collection("posts")
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({'likes.$uid': true});
      addLikeToActivityFeed(user: user);
    } else {
      likes.remove(uid);
      notifyListeners();
      Firestore.instance
          .collection("posts")
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({'likes.$uid': FieldValue.delete()});

      removeLikeFromActivityFeed(user: user);
    }
  }

  void addLikeToActivityFeed({User user}) {
    if (user.uid != ownerId) {
      Firestore.instance
          .collection("feed")
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": 0,
        "user": user.name,
        "userId": user.uid,
        "avatar": user.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "time": DateTime.now()
      });
    }
  }

  void removeLikeFromActivityFeed({User user}) {
    if (user.uid != ownerId) {
      Firestore.instance
          .collection("feed")
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
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
      {Post post, String uid, String name, String postId}) async {
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

  Future<Post> getPost({String postId, String userId}) async {
    print("[Post] userId: " +
        userId.toString() +
        " postId: " +
        postId.toString());
    DocumentSnapshot snapshot = await postRef
        .document(userId)
        .collection("userPosts")
        .document(postId)
        .get();
    print("[Post]: " + snapshot.data.toString());

    return snapshot.data == null ? null : Post.fromDocument(snapshot);
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

  void deletePost({String ownderId, String postId}) async {
    postRef
        .document(ownderId)
        .collection("userPosts")
        .document(postId)
        .get()
        .then((doc) => {
              if (doc.exists) {doc.reference.delete()}
            });

    storageRef.child("post_$postId.jpg").delete();

    QuerySnapshot feedSnapshot = await Firestore.instance
        .collection("feed")
        .document(ownderId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .getDocuments();

    feedSnapshot.documents.forEach((doc) => {
          if (doc.exists) {doc.reference.delete()}
        });

    QuerySnapshot commentsSnapshot = await Firestore.instance
        .collection("comments")
        .document(postId)
        .collection("comments")
        .getDocuments();

    commentsSnapshot.documents.forEach((doc) => {
          if (doc.exists) {doc.reference.delete()}
        });
  }
}
