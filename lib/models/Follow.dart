import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowProvider with ChangeNotifier {
  CollectionReference followingRef = Firestore.instance.collection("following");
  CollectionReference followersRef = Firestore.instance.collection("followers");
  CollectionReference activityFeed = Firestore.instance.collection("feed");

  void followUser({String usersId, String currentUserId}) {
    followersRef
        .document(usersId)
        .collection("followers")
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection('following')
        .document(usersId)
        .setData({});
  }

  void unfollowUser({String usersId, String currentUserId}) {
    followersRef
        .document(usersId)
        .collection("followers")
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .document(currentUserId)
        .collection('following')
        .document(usersId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> isFollowing({String userId, String followerId}) {
    followingRef
        .document(followerId)
        .collection("following")
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        return true;
      } else {
        return false;
      }
    });
  }
}
