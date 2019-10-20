import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

AppBar header(String text) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: Text(
      text,
      style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          LineIcons.search,
          size: 30,
        ),
        onPressed: () {
          //Show search screen
        },
      )
    ],
    centerTitle: true,
  );
}
