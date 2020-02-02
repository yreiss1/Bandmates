import 'dart:async';

import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/presentation/InstrumentIcons.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class MusiciansSearchScreen extends StatefulWidget {
  static const routeName = '/musicians-search';

  @override
  _MusiciansSearchScreenState createState() => _MusiciansSearchScreenState();
}

class _MusiciansSearchScreenState extends State<MusiciansSearchScreen> {
  bool _isLoading = false;
  int _selectedRadius;
  String _selectedInstrument;
  List<DropdownMenuItem> instruments = [];
  List<DropdownMenuItem> radii = [];
  List<User> _usersList = [];
  DocumentSnapshot _lastDocument;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  Timer searchOnStoppedTyping;
  TextEditingController _searchController = new TextEditingController();

  final GeoFirePoint center = currentUser.location;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.2;

      if (maxScroll - currentScroll <= delta) {
        _getMoreResults(_searchController.text);
      }
    });
    _selectedRadius = 50;

    Utils.instrumentList.forEach(
      (inst) => instruments.add(
        DropdownMenuItem(
          child: Text(inst.name),
          value: inst.name,
        ),
      ),
    );

    for (int i = 10; i <= 100; i += 20) {
      radii.add(DropdownMenuItem(
        child: Text(i.toString() + " Kilometers"),
        value: i,
      ));
    }
  }

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            400); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping =
        new Timer(duration, () => _getMoreResults(value)));
  }

  void _searchName(String query) async {
    setState(() {
      _isLoading = true;
    });
    List<User> results = [];

    QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .where("search", isGreaterThanOrEqualTo: query.toLowerCase())
        .limit(2)
        .getDocuments();

    snapshot.documents.forEach((doc) => results.add(User.fromDocument(doc)));

    if (!snapshot.documents.isEmpty) {
      _lastDocument = snapshot.documents[snapshot.documents.length - 1];
    }
    setState(() {
      _usersList = results;
      _isLoading = false;
    });
  }

  void _getMoreResults(query) async {
    if (!_hasMore || _isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot snapshot;
    if (_lastDocument == null) {
      snapshot = await Firestore.instance
          .collection('users')
          .where("search", isGreaterThanOrEqualTo: query.toLowerCase())
          .limit(10)
          .getDocuments();
    } else {
      snapshot = await Firestore.instance
          .collection('users')
          .where("search", isGreaterThanOrEqualTo: query.toLowerCase())
          .startAfterDocument(_lastDocument)
          .orderBy('search')
          .limit(10)
          .getDocuments();
    }

    if (snapshot.documents.length < 10) {
      _hasMore = false;
    }

    if (!snapshot.documents.isEmpty) {
      _lastDocument = snapshot.documents[snapshot.documents.length - 1];
    }
    List<User> results = [];
    snapshot.documents.forEach((doc) => results.add(User.fromDocument(doc)));

    setState(() {
      _usersList.addAll(results);
      _isLoading = false;
    });
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
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  buildSearchHeader(context),
                                  Flexible(
                                    child: buildMainArea(context),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: 140,
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Chip(
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  label: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: _searchController,
                                    onChanged: (value) {
                                      _onChangeHandler(value);
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
      padding: EdgeInsets.only(
        left: 12,
      ),
      height: 170,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: 0,
            title: Text(
              "Search Musicians",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Transform(
                transform: new Matrix4.identity()..scale(0.9),
                child: Chip(
                  elevation: 10,
                  backgroundColor: Colors.white,
                  label: DropdownButton(
                    icon: Icon(FontAwesome5Solid.guitar),
                    value: _selectedInstrument,
                    hint: Text("Instrument"),
                    items: instruments,
                    onChanged: (value) {
                      setState(() {
                        _selectedInstrument = value;
                      });
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
                    icon: Icon(FontAwesome5Solid.ruler_horizontal),
                    value: _selectedRadius,
                    hint: Text("Distance"),
                    items: radii,
                    onChanged: (value) {
                      setState(() {
                        _selectedRadius = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.76,
        child: _searchController.text.isEmpty
            ? StreamBuilder(
                stream: Provider.of<UserProvider>(context)
                    .getClosest(center, _selectedRadius, _selectedInstrument),
                builder: (BuildContext context,
                    AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress(context);
                  }

                  if (snapshot.hasError) {
                    Utils.buildErrorDialog(context,
                        "Error fetching data, please try again later!");
                  }

                  if (snapshot.data.length == 0) {
                    return Center(
                      child: Text(
                          "No musicians in your area, please try again later!"),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      User user = User.fromDocument(snapshot.data[index]);
                      if (user.uid == currentUser.uid) {
                        return Container();
                      }
                      return buildUserCard(user, context);
                    },
                  );
                },
              )
            : _isLoading
                ? Center(child: circularProgress(context))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 30),
                    itemCount: _usersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      User user = _usersList[index];
                      if (user.uid == currentUser.uid) {
                        return Container();
                      }
                      return buildUserCard(user, context);
                    },
                  ));
  }

  buildUserCard(User user, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName,
          arguments: ProfileScreenArguments(userId: user.uid)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 35,
                      backgroundImage: user.photoUrl == null
                          ? AssetImage('assets/images/user-placeholder.png')
                          : CachedNetworkImageProvider(user.photoUrl),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            user.location
                                    .distance(
                                        lat: currentUser.location.latitude,
                                        lng: currentUser.location.longitude)
                                    .toStringAsFixed(1) +
                                " km away",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        ],
                      ),
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
                user.instruments.length > 3
                    ? Row(
                        children: <Widget>[
                          for (String inst in user.instruments.sublist(0, 3))
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: Chip(
                                  label: Text(inst),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: 8,
                          ),
                          Text("+" +
                              (user.instruments.length - 3).toString() +
                              " More"),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          for (String inst in user.instruments)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              child: Chip(
                                label: Text(inst),
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
                user.genres.length > 3
                    ? Row(
                        children: <Widget>[
                          for (String genre in user.genres.sublist(0, 3))
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              child: Chip(
                                label: Text(genre),
                              ),
                            ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            ("+" +
                                (user.genres.length - 3).toString() +
                                " More"),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          for (String genre in user.genres)
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
      ),
    );
  }
}
