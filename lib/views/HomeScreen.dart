import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/FeedScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/OnboardingScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/InstrumentIcons.dart';
import './ChatsScreen.dart';
import './UploadScreen.dart';
import './TimelineScreen.dart';
import './UI/Progress.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import 'dart:async';
import 'dart:io';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PageController _pageController;
  int pageIndex = 0;
  User _currentUser;
  Stream<DocumentSnapshot> _getUserStream;

  ChatsScreen _chatScreen;
  UploadScreen _uploadScreen;
  FeedScreen _feedScreen;
  ProfileScreen _profileScreen;

  OnboardingScreen _onboardingScreen;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserStream = getStream(widget.uid);

    _pageController = PageController(keepPage: false);

    _onboardingScreen = OnboardingScreen();

    _chatScreen = ChatsScreen();
    _uploadScreen = UploadScreen();
    _feedScreen = FeedScreen();
    _profileScreen = ProfileScreen(ProfileScreenArguments(userId: widget.uid));
  }

  Stream<DocumentSnapshot> getStream(String uid) {
    Stream<DocumentSnapshot> snapshot =
        Firestore.instance.collection('users').document(uid).snapshots();

    snapshot.first.then((documentSnapshot) {
      User user = User.fromDocument(documentSnapshot);

      _currentUser = user;
      currentUser = user;
    });

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

  obtainPushNotifications() {
    if (Platform.isIOS) {
      getiOSPermission();
    }

    _firebaseMessaging.getToken().then((token) {
      print("Firebase messaging token $token\n");
      currentUser.token = token;

      Firestore.instance
          .collection("users")
          .document(widget.uid)
          .updateData({"token": token});
    });
  }

  configurePushNotifications() {
    _firebaseMessaging.configure(
        onLaunch: (Map<String, dynamic> message) async {},
        onResume: (Map<String, dynamic> message) async {},
        onMessage: (Map<String, dynamic> message) async {
          print("[HomeScreen] onMessage: $message\n");

          final String recipientId = message['data']['recipient'];
          final String body = message['notification']['body'];

          if (recipientId == widget.uid) {
            SnackBar snackBar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ),
            );

            _scaffoldKey.currentState.showSnackBar(snackBar);
          }
        });
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("[HomeScreen] Rebuilding the widget");

    return SafeArea(
      top: false,
      bottom: false,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _getUserStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.error == null && snapshot.data != null) {
            if (snapshot.data.data == null) {
              return Scaffold(body: _onboardingScreen);
            } else {
              if (snapshot.data.data['token'] == null) {
                obtainPushNotifications();
              }
              configurePushNotifications();

              currentUser = User.fromDocument(snapshot.data);
              return SafeArea(
                top: false,
                child: Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  key: _scaffoldKey,
                  body: PageView(
                    children: <Widget>[
                      TimelineScreen(),
                      _chatScreen,
                      _uploadScreen,
                      _feedScreen,
                      _profileScreen
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
                      BottomNavigationBarItem(icon: Icon(Icons.today)),
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
