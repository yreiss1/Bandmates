import 'package:bandmates/views/SearchScreens/ClassifiedSearchScreen.dart';
import 'package:bandmates/views/SearchScreens/EventsSearchScreen.dart';
import 'package:bandmates/views/SearchScreens/MusiciansSearchScreen.dart';
import 'package:bandmates/views/UploadScreens/ClassifiedUploadScreen.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/Chat.dart';
import 'package:bandmates/models/Follow.dart';
import 'package:bandmates/models/Post.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/DiscoverScreen.dart';
import 'package:bandmates/views/LandingScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/UploadScreens/EventUploadScreen.dart';
import 'package:bandmates/views/UploadScreens/PostUploadScreen.dart';
import './views/HomeScreen.dart';
import './views/StartScreen.dart';
import './models/Event.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './AuthService.dart';
import 'models/Classified.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) {
            return AuthService();
          },
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) {
            return UserProvider();
          },
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (_) {
            return PostProvider();
          },
        ),
        ChangeNotifierProvider<EventProvider>(
          create: (_) {
            return EventProvider();
          },
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) {
            return ChatProvider();
          },
        ),
        ChangeNotifierProvider<FollowProvider>(
          create: (_) {
            return FollowProvider();
          },
        ),
        ChangeNotifierProvider<ClassifiedProvider>(
          create: (_) {
            return ClassifiedProvider();
          },
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bandmates',
        theme: ThemeData(
          primaryColor: Color(0xff53172c),
          accentColor: Color(0xff829abe),
          backgroundColor: Colors.white,
          fontFamily: 'Montserrat',
        ),
        home: LandingScreen(),
        routes: {
          // Here we add routes to different pages
          StartScreen.routeName: (ctx) => StartScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          ProfileScreen.routeName: (ctx) =>
              ProfileScreen(ModalRoute.of(ctx).settings.arguments),
          DiscoverScreen.routeName: (ctx) =>
              DiscoverScreen(ModalRoute.of(ctx).settings.arguments),
          PostUploadScreen.routeName: (ctx) => PostUploadScreen(),
          EventUploadScreen.routeName: (ctx) => EventUploadScreen(),
          MusiciansSearchScreen.routeName: (ctx) => MusiciansSearchScreen(),
          EventsSearchScreen.routeName: (ctx) => EventsSearchScreen(),
          ClassifiedUploadScreen.routeName: (ctx) => ClassifiedUploadScreen(),
          ClassifiedSearchScreen.routeName: (ctx) => ClassifiedSearchScreen(),
        },
      ),
    );
  }
}
