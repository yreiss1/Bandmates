import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import './UI/NestedTabBar.dart';

class UserScreen extends StatelessWidget {
  static const routeName = '/user-screen';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            child: Container(
                              color: Colors.purple,
                              constraints: BoxConstraints(
                                  maxHeight: 180,
                                  maxWidth: MediaQuery.of(context).size.width),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          Text(
                            "Omer Yampel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Here I talk alittle about myself and my interests",
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                shape: StadiumBorder(),
                                color: Colors.purple,
                                onPressed: () {
                                  print("Following");
                                },
                                textColor: Colors.white,
                                child: Text(
                                  "FOLLOWING",
                                ),
                              ),
                              OutlineButton(
                                textColor: Colors.purple,
                                shape: StadiumBorder(),
                                onPressed: () {
                                  print("Message");
                                },
                                child: Text("MESSAGE"),
                              )
                            ],
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints.expand(height: 360),
                        child: CircularProfileAvatar(
                          "http://hdwpro.com/wp-content/uploads/2016/10/Nice-Bunny-Photo.jpeg",
                          cacheImage: true,
                          radius: 80,
                          elevation: 5.0,
                          borderColor: Colors.white,
                          borderWidth: 5,
                          onTap: () {
                            print("Hello World!");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Colors.black26),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "130",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text("Followers"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Colors.black26),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "26",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text("Years Playing"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Colors.black26),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "2",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text("Previous Bands"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                NestedTabBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
