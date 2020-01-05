import 'package:flutter/material.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/SearchScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../../AuthService.dart';
import '../../models/User.dart';

AppBar mainHeader(String text, BuildContext context) {
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
          User user = Provider.of<UserProvider>(context).user;
          print("[Header] user uid: " + user.uid);
          //Show search screen
          Navigator.pushNamed(context, ProfileScreen.routeName,
              arguments: ProfileScreenArguments(userId: user.uid));
        },
      )
    ],
    centerTitle: true,
  );
}

AppBar header(String text, BuildContext context) {
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
          LineIcons.user,
          color: Color(0xFF1d1e2c),
          size: 30,
        ),
        onPressed: () {
          User user = Provider.of<UserProvider>(context).user;
          print("[Header] user uid: " + user.uid);
          //Show search screen
          Navigator.pushNamed(context, ProfileScreen.routeName,
              arguments: ProfileScreenArguments(userId: user.uid));
        },
      ),
      IconButton(
          icon: Icon(
            Icons.exit_to_app,
            color: Color(0xFF1d1e2c),
            size: 30,
          ),
          onPressed: () => Provider.of<AuthService>(context).signOut())
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

          fbKey.currentState.saveAndValidate();
        },
      )
    ],
    centerTitle: true,
  );
}
