import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/user.dart';

class Utils {
  static final _usersRef = Firestore.instance.collection('users');

  static String _uid;
  static String _email;
  static User _user;

  static void setUser(User currentUser) {
    _user = currentUser;
  }

  static User getUser() {
    return _user;
  }

  static void setUid(String uid) {
    _uid = uid;
  }

  static void setEmail(String email) {
    _email = email;
  }

  static String getUid() {
    return _uid;
  }

  static String getEmail() {
    return _email;
  }

  static Future buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  static Future<bool> isNew(context) async {
    final DocumentSnapshot doc = await _usersRef.document(getUid()).get();

    return doc == null;
  }

  //TODO: make it so that the photo path does not get overwridden by
  static void uploadPhotoPath(context, String path) async {
    var userAuth = Provider.of<FirebaseUser>(context, listen: false);

    await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .setData({
      'img': path,
    });
  }
}
