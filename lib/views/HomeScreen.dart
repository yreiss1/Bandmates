import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/OnboardingScreen.dart';
import 'package:jammerz/views/SearchScreen.dart';
import 'package:jammerz/views/UI/Header.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/InstrumentIcons.dart';
import './ChatsScreen.dart';
import './UploadScreen.dart';
import './TimelineScreen.dart';
import './ActivityScreen.dart';
import './UI/Progress.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import 'ProfileScreen.dart';
import '../models/ProfileScreenArguments.dart';
import 'dart:async';

User currentUser;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  final String uid;

  HomeScreen({this.uid});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  PageController _pageController;
  int pageIndex = 0;
  User _currentUser;
  Future<DocumentSnapshot> _getUser;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _getUser = getSnapshot(widget.uid);
  }

  Future<DocumentSnapshot> getSnapshot(String uid) async {
    print("[HomeScreen] In getSnapshot");
    DocumentSnapshot snapshot =
        await Provider.of<UserProvider>(context, listen: false)
            .getSnapshot(widget.uid);
    User user = User.fromDocument(snapshot);
    setState(() {
      _currentUser = user;
    });
    Provider.of<UserProvider>(context).setCurrentUser(user);
    return snapshot;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    _pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: _getUser,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.error == null && snapshot.data != null) {
            if (snapshot.data.data == null) {
              return Scaffold(
                body: OnboardingScreen(),
              );
            } else {
              print("[HomeScreen] rebuilt the widget");
              print("[HomeScreen] currentUser: " + _currentUser.uid.toString());
              return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  title: Text(
                    "Bandmates",
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
                        Navigator.pushNamed(context, ProfileScreen.routeName,
                            arguments:
                                ProfileScreenArguments(user: _currentUser));
                      },
                    )
                  ],
                  centerTitle: true,
                ),
                body: PageView(
                  children: <Widget>[
                    TimelineScreen(),
                    ChatsScreen(),
                    UploadScreen(),
                    ActivityScreen(),
                    SearchScreen(
                      currentUser: _currentUser,
                    ),
                  ],
                  controller: _pageController,
                  onPageChanged: onPageChanged,
                  physics: AlwaysScrollableScrollPhysics(),
                  pageSnapping: true,
                ),
                bottomNavigationBar: CupertinoTabBar(
                  currentIndex: pageIndex,
                  onTap: onTap,
                  activeColor: Theme.of(context).primaryColor,
                  items: [
                    BottomNavigationBarItem(icon: Icon(LineIcons.fire)),
                    BottomNavigationBarItem(icon: Icon(LineIcons.comments_o)),
                    BottomNavigationBarItem(
                        icon: Icon(
                      InstrumentIcons.hand,
                      size: 35.0,
                    )),
                    BottomNavigationBarItem(icon: Icon(LineIcons.bell_o)),
                    BottomNavigationBarItem(icon: Icon(LineIcons.search)),
                  ],
                ),
              );
            }
          } else {
            return Scaffold(
              body: circularProgress(context),
            );
          }
        },
      ),
    );
  }
}
