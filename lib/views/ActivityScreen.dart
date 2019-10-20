import 'package:flutter/material.dart';
import 'UI/Header.dart';

class ActivityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("Activity"),
      body: Center(
        child: Text("Activity Screen"),
      ),
    );
  }
}
