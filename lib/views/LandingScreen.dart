import 'package:flutter/material.dart';
import 'package:jammerz/views/HomeScreen.dart';
import 'package:jammerz/views/StartScreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/musicians.jpg"), context);
    precacheImage(AssetImage("assets/images/concert.jpg"), context);
    precacheImage(AssetImage("assets/images/silhouette.jpg"), context);

    var user = Provider.of<FirebaseUser>(context);
    return user != null ? HomeScreen() : StartScreen();
  }
}
