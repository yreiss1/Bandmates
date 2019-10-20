import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/OnboardingScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../presentation/InstrumentIcons.dart';
import './ChatsScreen.dart';
import './ProfileScreen.dart';
import './TimelineScreen.dart';
import './DiscoverScreen.dart';
import './ActivityScreen.dart';
import './UI/Progress.dart';
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
    return FutureBuilder<DocumentSnapshot>(
      future:
          Firestore.instance.collection('users').document(Utils.getUid()).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.error == null && snapshot.data != null) {
          if (!snapshot.data.exists) {
            return Scaffold(
              body: OnboardingScreen(),
            );
          } else {
            currentUser = User.fromDocument(snapshot.data);
            return Scaffold(
              body: PageView(
                children: <Widget>[
                  TimelineScreen(),
                  ChatsScreen(),
                  DiscoverScreen(),
                  ActivityScreen(),
                  ProfileScreen()
                ],
                controller: _pageController,
                onPageChanged: onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                pageSnapping: false,
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
                  BottomNavigationBarItem(icon: Icon(LineIcons.user)),
                ],
              ),
            );
          }
        } else {
          return circularProgress(context);
        }
      },
    );
  }
}
