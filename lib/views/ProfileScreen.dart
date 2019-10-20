import 'package:flutter/material.dart';
import 'package:jammerz/AuthService.dart';
import 'package:jammerz/views/UI/Header.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("Profile"),
      body: Center(
        child: RaisedButton(
          child: Text(
            "SIGN OUT",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Provider.of<AuthService>(context).signOut();
          },
        ),
      ),
    );
  }
}
