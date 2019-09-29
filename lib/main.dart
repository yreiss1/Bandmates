import 'package:flutter/material.dart';
import 'package:jammerz/views/HomeScreen.dart';

import 'package:jammerz/views/LoginScreen.dart';
import 'package:jammerz/views/UserScreen.dart';
import './views/ChatScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jammerz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserScreen(),
      routes: {
        // Here we add routes to different pages
        HomeScreen.routeName: (ctx) => HomeScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        ChatScreen.routeName: (ctx) => ChatScreen(),
        UserScreen.routeName: (ctx) => UserScreen()
      },
    );
  }
}
