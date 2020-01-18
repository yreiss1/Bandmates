import 'package:flutter/material.dart';
import 'package:bandmates/views/LoginScreen.dart';
import 'package:bandmates/views/SignupScreen.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/start-screen';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 60,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor:
                              const Color(0xFFFFFFFF).withOpacity(0.54),
                          isScrollable: true,
                          tabs: <Widget>[
                            Text(
                              "Sign In",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[LoginScreen(), SignupScreen()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
