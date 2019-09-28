import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jammerz"),
      ),
      body: Center(
        child: Text("This is the Login Page"),
      ),
    );
  }
}
