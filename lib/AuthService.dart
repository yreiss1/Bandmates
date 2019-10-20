import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInWithCredentials(
      {String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }

  Future<FirebaseUser> signUp(
      {String email, String password, BuildContext context}) async {
    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();
      return result;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }

  Future signOut() async {
    var result = _firebaseAuth.signOut();
    notifyListeners();
    return result;
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {
    //TODO: File out and return user model
    FirebaseUser user = await _firebaseAuth.currentUser();

    return user;
  }
}
