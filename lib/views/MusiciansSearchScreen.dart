import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/MusiciansScreenArguments.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class MusiciansSearchScreen extends StatefulWidget {
  static const routeName = '/musicians-search';

  final MusiciansScreenArguments arguments;

  MusiciansSearchScreen(this.arguments);

  @override
  _MusiciansSearchScreenState createState() => _MusiciansSearchScreenState();
}

class _MusiciansSearchScreenState extends State<MusiciansSearchScreen> {
  bool _isLoading = false;
  String selectedGenre;
  String selectedInstrument;
  List<DropdownMenuItem> instruments = [];
  List<DropdownMenuItem> genres = [];
  List<User> _usersList = [];

  @override
  void initState() {
    super.initState();
    _usersList = widget.arguments.userList;

    Utils.instrumentList.forEach(
      (inst) => instruments.add(
        DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Icon(
                inst.icon.icon,
                size: 40,
              ),
              SizedBox(
                width: 10,
              ),
              Text(inst.name)
            ],
          ),
          value: inst.value,
        ),
      ),
    );
    /*
    instruments.insert(
      0,
      DropdownMenuItem(
        child: Text("None"),
        value: null,
      ),
    );*/

    Utils.genresList.forEach(
      (genre) => genres.add(
        DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Icon(
                genre.icon.icon,
                size: 40,
              ),
              SizedBox(
                width: 10,
              ),
              Text(genre.name)
            ],
          ),
          value: genre.value,
        ),
      ),
    );
    // genres.insert(
    //   0,
    //   DropdownMenuItem(
    //     child: Text("None"),
    //     value: null,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white, // Theme.of(context).primaryColor,
          body: Container(

              //height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  buildSearchHeader(context),
                                  buildMainArea(context),
                                ],
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: 170,
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Chip(
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  label: TextField(
                                    onChanged: (value) {
                                      if (value.length > 3) {
                                        _searchName(value);
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(Icons.search),
                                        hintText: "Search by name"),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ],
              )),
        ),
      ),
    );
  }

  buildSearchHeader(context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 32),
      height: 200,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  LineIcons.long_arrow_left,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Search Musicians",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ],
          ),
          SizedBox(
            height: 24,
          ),
          buildChipInputs()
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
      padding: EdgeInsets.only(top: 0),
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.80,
      width: double.infinity,
      child: _isLoading == true
          ? Center(
              child: circularProgress(context),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 30),
              itemCount: _usersList.length,
              itemBuilder: (BuildContext context, int index) {
                return buildUserCard(_usersList[index]);
              },
            ),
    );
  }

  buildChipInputs() {
    return Container(
      height: 50,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: DropdownButton(
                value: selectedInstrument,
                hint: Text("Instrument"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    selectedInstrument = value;
                  });
                  _searchUsers();
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: DropdownButton(
                value: selectedGenre,
                hint: Text("Genre"),
                items: genres,
                onChanged: (value) {
                  setState(() {
                    selectedGenre = value;
                  });
                  _searchUsers();
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: DropdownButton(
                hint: Text("Transportation"),
                items: [
                  DropdownMenuItem(
                    child: Text("Has"),
                    value: true,
                  ),
                  DropdownMenuItem(
                    child: Text("Has Not"),
                    value: false,
                  ),
                  DropdownMenuItem(
                    child: Text("None"),
                    value: null,
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    //selectedInstrument = value;
                  });
                  _searchUsers();
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: SearchableDropdown(
                hint: Text("Practice Space"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    //selectedInstrument = value;
                  });
                  _searchUsers();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchName(String query) async {
    setState(() {
      _isLoading = true;
    });
    List<User> results = [];
    await Firestore.instance
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: query.toUpperCase())
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) => results.add(User.fromDocument(doc)));
    });

    setState(() {
      _usersList = results;
      _isLoading = false;
    });
  }

  void _searchUsers() async {
    setState(() {
      _isLoading = true;
    });
    Query query = Firestore.instance.collection("users");

    if (selectedInstrument != null) {
      query = query.where("instruments.$selectedInstrument", isEqualTo: true);
    }
    if (selectedGenre != null) {
      query = query.where("genres.$selectedGenre", isEqualTo: true);
    }

    QuerySnapshot snapshot = await query.getDocuments();

    List<User> results = [];
    snapshot.documents.forEach((doc) {
      results.add(User.fromDocument(doc));
    });

    setState(() {
      _usersList = results;
      _isLoading = false;
    });
  }

  String buildSubtitle(Map<dynamic, dynamic> map) {
    List l = map.keys.toList();

    String result = l.fold(
        "",
        (inc, ins) =>
            inc +
            " " +
            ins.toString()[0].toUpperCase() +
            ins.toString().substring(1) +
            " " +
            "\\");

    result = result.substring(1, result.length - 1);
    if (result.length > 40) {
      result = result.substring(0, 40);
      result += "...";
    }
    return result;
  }
}

buildUserCard(User user) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: user.photoUrl == null
                      ? AssetImage('assets/images/user-placeholder.png')
                      : CachedNetworkImageProvider(user.photoUrl),
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      user.location
                              .distance(
                                  lat: currentUser.location.latitude,
                                  lng: currentUser.location.longitude)
                              .round()
                              .toString() +
                          "km away",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Instruments: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                for (String inst in user.instruments.keys)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Utils.valueToIcon(inst),
                      size: 30,
                    ),
                  )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Genres: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                for (String genre in user.genres.keys)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: Chip(
                      label: Text(genre),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
