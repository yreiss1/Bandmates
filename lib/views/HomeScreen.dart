import 'package:flutter/material.dart';
import 'package:jammerz/views/LoginScreen.dart';
import './ChatScreen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home-screen';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.music_note),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chat_bubble),
              onPressed: () =>
                  Navigator.pushNamed(context, ChatScreen.routeName),
            ),
            IconButton(
              icon: Icon(Icons.group),
              onPressed: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Jammerz"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          )
        ],
      ),
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          "https://thumbnailer.mixcloud.com/unsafe/1200x628/tmp/7/4/2/8/fac1-7b75-4a97-a54c-02d8d853fa48"),
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        child: Text(
                          "Omer Yampel",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "Guitarist",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
