import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'AuthService.dart';
import './models/user.dart';

class Utils {
  static final _usersRef = Firestore.instance.collection('users');

  static String _uid;
  static String _email;

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
    final DocumentSnapshot doc = await _usersRef
        .document((await Provider.of<AuthService>(context).getUser()).uid)
        .get();

    return doc == null;
  }

  static void uploadUser(context, User user) async {
    print("In uploadUser" + user.instruments.toString());
    await Firestore.instance
        .collection("users")
        .document((await Provider.of<AuthService>(context).getUser()).uid)
        .setData(user.toJson());
  }

  static void uploadPhotoPath(context, String path) async {
    await Firestore.instance
        .collection('users')
        .document((await Provider.of<AuthService>(context).getUser()).uid)
        .setData({
      'img': path,
    });
  }
}
