import 'package:flutter/material.dart';
import 'package:jammerz/views/ProfileScreen.dart';
import 'package:jammerz/views/SearchScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

AppBar header(String text, BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: Text(
      text,
      style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
    ),
    leading: Container(),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          LineIcons.user,
          color: Color(0xFF1d1e2c),
          size: 30,
        ),
        onPressed: () {
          //Show search screen
          Navigator.pushNamed(context, ProfileScreen.routeName);
        },
      )
    ],
    centerTitle: true,
  );
}

AppBar uploadHeader(
    String text, BuildContext context, GlobalKey<FormBuilderState> fbKey) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: Text(
      text,
      style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
    ),
    leading: IconButton(
      icon: Icon(
        LineIcons.arrow_left,
        color: Color(0xFF1d1e2c),
      ),
      onPressed: () => Navigator.pop(context),
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          LineIcons.check,
          color: Color(0xFF1d1e2c),
          size: 30,
        ),
        onPressed: () {
          //Show search screen
          print("Submitted!");

          fbKey.currentState.saveAndValidate();
        },
      )
    ],
    centerTitle: true,
  );
}
