import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/OnboardingScreen.dart';
import 'package:jammerz/views/SearchScreen.dart';
import 'package:jammerz/views/UI/Header.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/InstrumentIcons.dart';
import './ChatsScreen.dart';
import './UploadScreen.dart';
import './TimelineScreen.dart';
import './ActivityScreen.dart';
import './UI/Progress.dart';
import 'package:provider/provider.dart';
import '../Utils.dart';
import '../models/user.dart';

User currentUser;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
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
    
    var user = Provider.of<FirebaseUser>(context);
    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance.collection('users').document(user.uid).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.error == null && snapshot.data != null) {
            if (!snapshot.data.exists) {
              return Scaffold(
                body: OnboardingScreen(),
              );
            } else {
              return Scaffold(
                appBar: header("Bandmates", context),
                body: PageView(
                  children: <Widget>[
                    TimelineScreen(),
                    ChatsScreen(),
                    UploadScreen(),
                    ActivityScreen(),
                    SearchScreen(),
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
            return circularProgress(context);
          }
        },
      ),
    );
  }
}
