import 'package:flutter/material.dart';
import 'package:jammerz/views/EditProfileScreen.dart';
import 'package:jammerz/views/LoginScreen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jammerz"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, EditProfile.routeName);
            },
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text("This is the home screen"),
        ),
      ),
    );
  }
}
