import 'package:flutter/material.dart';
import 'package:jammerz/views/OnboardingScreens/ImageCapture.dart';
import './views/HomeScreen.dart';
import './views/StartScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './AuthService.dart';
import './Utils.dart';

void main() => runApp(
      ChangeNotifierProvider<AuthService>(
        child: MyApp(),
        builder: (BuildContext context) {
          return AuthService();
        },
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandmates',
      theme: ThemeData(
        primaryColor: Color(0xff53172c),
        accentColor: Color(0xff53172c),
        fontFamily: 'Montserrat',
      ),
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              Utils.setEmail(snapshot.data.email.toString());
              Utils.setUid(snapshot.data.uid.toString());
              return snapshot.hasData ? HomeScreen() : StartScreen();
            } else {
              return StartScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      routes: {
        // Here we add routes to different pages
        StartScreen.routeName: (ctx) => StartScreen(),
        ImageCapture.routeName: (ctx) => ImageCapture(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
      },
    );
  }
}
