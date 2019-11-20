import 'package:flutter/material.dart';
import 'package:jammerz/AuthService.dart';
import 'package:jammerz/models/ProfileScreenArguments.dart';
import 'package:jammerz/views/UI/ProfileScreenBody.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatelessWidget {
  static final routeName = '/profile-screen';

  final ProfileScreenArguments profileParams;

  ProfileScreen(this.profileParams);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFF1d1e2c)),
          leading: IconButton(
            icon: Icon(LineIcons.arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                LineIcons.edit,
                color: Color(0xFF1d1e2c),
                size: 30,
              ),
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(EditProfileScreen.routeName),
            ),
            IconButton(
              icon: Icon(
                LineIcons.sign_out,
                color: Color(0xFF1d1e2c),
                size: 30,
              ),
              onPressed: () {
                Provider.of<AuthService>(context).signOut();
                Navigator.pop(context);
              },
            ),
          ],
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            "Profile",
            style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
          ),
        ),
        body: ProfileScreenBody(user: profileParams.user));
  }
}
