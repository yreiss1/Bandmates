import 'package:flutter/material.dart';
import 'package:jammerz/AuthService.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  static final routeName = '/profile-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF1d1e2c)),
        leading: IconButton(
          icon: Icon(LineIcons.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
        ),
      ),
      body: Center(
        child: RaisedButton(
          child: Text(
            "SIGN OUT",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            await Provider.of<AuthService>(context).signOut();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
