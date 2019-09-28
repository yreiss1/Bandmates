import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jammerz"),
      ),
      body: Container(
        child: Center(
          child: Text("This is the home screen"),
        ),
      ),
    );
  }
}
