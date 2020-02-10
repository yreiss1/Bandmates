import 'dart:async';

import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/Classified.dart';
import 'package:bandmates/models/Event.dart';
import 'package:bandmates/views/ClassifiedScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../HomeScreen.dart';

class ClassifiedSearchScreen extends StatefulWidget {
  @override
  _ClassifiedSearchScreenState createState() => _ClassifiedSearchScreenState();
}

class _ClassifiedSearchScreenState extends State<ClassifiedSearchScreen> {
  int _selectedType;
  int _selectedRadius;
  bool _searching = false;
  bool _hasMore = true;
  DocumentSnapshot _lastDocument;
  List<DropdownMenuItem> radii = [];
  List<Classified> _classifiedList = [];
  bool _isLoading = false;
  ScrollController _scrollController;
  TextEditingController _searchController;
  Timer searchOnStoppedTyping;

  final GeoFirePoint center = currentUser.location;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.2;

      if (maxScroll - currentScroll <= delta) {
        _getMoreResults(_searchController.text);
      }
    });

    for (int i = 10; i <= 100; i += 20) {
      radii.add(DropdownMenuItem(
        child: Text(i.toString() + " Kilometers"),
        value: i,
      ));
    }

    _selectedRadius = 30;
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
          .collection('events')
          .where("search", isGreaterThanOrEqualTo: query.toLowerCase())
          .limit(10)
          .getDocuments();
    } else {
      snapshot = await Firestore.instance
          .collection('events')
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
    List<Classified> results = [];
    snapshot.documents
        .forEach((doc) => results.add(Classified.fromDocument(doc)));

    setState(() {
      _classifiedList.addAll(results);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _buildSearchHeader(context) {
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
              "Search Ads",
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
                    icon: Icon(LineIcons.search),
                    value: _selectedType,
                    hint: Text("Ad Type"),
                    onChanged: (int value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text("Selling"),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text("Buying"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("Looking For"),
                        value: 2,
                      ),
                    ],
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
          ),
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.76,
        child: _searchController.text.isEmpty
            ? StreamBuilder(
                stream: Provider.of<ClassifiedProvider>(context)
                    .getClosest(center, _selectedRadius, _selectedType),
                builder: (BuildContext context,
                    AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasError) {
                    Utils.buildErrorDialog(context,
                        "There is an error fetching data, please try again later!");
                  }

                  if (!snapshot.hasData) {
                    return circularProgress(context);
                  }

                  if (snapshot.data.isEmpty) {
                    return Center(
                      child: Text(
                          "There are no ads currently posted in your area!"),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildClassifiedCard(
                          Classified.fromDocument(snapshot.data[index]));
                    },
                  );
                },
              )
            : _isLoading
                ? Center(child: circularProgress(context))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 30),
                    itemCount: _classifiedList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildClassifiedCard(_classifiedList[index]);
                    },
                  ));
  }

  _buildClassifiedCard(Classified classified) {
    return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => ClassifiedScreen(
                      classified: classified,
                    ))),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        classified.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor)),
                        child: Text(
                          Utils.deserializeClassifiedType(classified.type),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(classified.username),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 150,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 5,
                          child: classified.photoUrl != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          classified.photoUrl),
                                    ),
                                  ),
                                )
                              // : GoogleMap(
                              //     scrollGesturesEnabled: false,
                              //     zoomGesturesEnabled: false,
                              //     myLocationButtonEnabled: false,
                              //     mapType: MapType.normal,
                              //     initialCameraPosition: CameraPosition(
                              //       target: LatLng(event.location.latitude,
                              //           event.location.longitude),
                              //       zoom: 14.0000,
                              //     ),
                              //     markers: {
                              //       Marker(
                              //           markerId: MarkerId("Event Location"),
                              //           position: LatLng(event.location.latitude,
                              //               event.location.longitude))
                              //     },
                              //   ),
                              : Container()),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    classified.text,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    classified.location
                            .distance(
                                lat: currentUser.location.latitude,
                                lng: currentUser.location.longitude)
                            .round()
                            .toString() +
                        " km away",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
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
                              children: <Widget>[
                                _buildSearchHeader(context),
                                buildMainArea(context),
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
            ),
          ),
        ),
      ),
    );
  }
}
