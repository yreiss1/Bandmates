import 'package:flutter/material.dart';

class NestedTabBar extends StatefulWidget {
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  TabController _nestedTabController;

  @override
  void initState() {
    super.initState();

    _nestedTabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  List<String> _genres = ["Rock", "Metal", "Alternative", "EDM"];
  List<String> _instruments = [
    "Guitar",
    "Bass",
    "Microphone",
    "Drums",
    "Boss Katana",
    "Fender Strat",
    "Gibson Les Paul",
    "Schecter C1",
    "Epiphone SG"
  ];

  List<String> _work = ["Link1", "Link2", "Link3"];

  List<String> _influences = ["70's", "80's", "90's", "Slash"];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TabBar(
          controller: _nestedTabController,
          indicatorColor: Theme.of(context).accentColor,
          labelColor: Theme.of(context).accentColor,
          unselectedLabelColor: Colors.black54,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              text: "Infleunces",
            ),
            Tab(
              text: "Gear",
            ),
            Tab(
              text: "Work",
            ),
            Tab(
              text: "Location",
            ),
            Tab(
              text: "Availabile",
            ),
          ],
        ),
        Container(
          height: screenHeight * 0.20,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: TabBarView(
            controller: _nestedTabController,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _influences.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemBuilder: (BuildContext ctx, int index) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        _influences[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    );
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _instruments.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemBuilder: (BuildContext ctx, int index) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        _instruments[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    );
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _work.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemBuilder: (BuildContext ctx, int index) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        _work[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.indigoAccent,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
