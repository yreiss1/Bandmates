import 'package:flutter/material.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/UI/ProfileScreenBody.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static final routeName = '/profile-screen';

  final ProfileScreenArguments profileParams;

  ProfileScreen(this.profileParams);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future:
            Provider.of<UserProvider>(context).getUser(profileParams.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          return ProfileScreenBody(user: snapshot.data);
        },
      ),
    );
  }
}
