import 'dart:async';

import 'package:bandmates/models/Event.dart';
import 'package:bandmates/models/EventsScreenArguments.dart';
import 'package:bandmates/models/MusiciansScreenArguments.dart';
import 'package:bandmates/views/EventsSearchScreen.dart';
import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/MusiciansSearchScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import '../Utils.dart';

import '../models/User.dart';

final usersRef = Firestore.instance.collection('users');

class TimelineScreen extends StatefulWidget {
  final User currentUser;

  TimelineScreen({this.currentUser});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool _isLoading = false;
  List<User> _userList;
  List<Event> _eventList;
  final Geoflutterfire geo = Geoflutterfire();
  final GeoFirePoint center = prefix0.currentUser.location;

  @override
  void initState() {
    super.initState();
    _userList = [];
    _eventList = [];
    getTimeline();
  }

  Future<void> getTimeline() async {
    setState(() {
      _isLoading = true;
    });

    var collectionReference = Firestore.instance.collection('events');

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: 100, field: 'loc', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        setState(() {
          _eventList.add(Event.fromDocument(doc));
        });
      });
    });

    var userReference = Firestore.instance.collection('users');
    Stream<List<DocumentSnapshot>> userStream = geo
        .collection(collectionRef: userReference)
        .within(
            center: center, radius: 100, field: 'location', strictMode: true);

    userStream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        setState(() {
          if (doc.documentID != prefix0.currentUser.uid) {
            _userList.add(User.fromDocument(doc));
          }
        });
      });
    });

    setState(() {
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

  @override
  Widget build(BuildContext context) {
    print("[Timeline] Rebuilding the widget");

    return ListView(
      children: <Widget>[
        buildSearchHeader(),
        buildMainArea(),
      ],
    );
  }

  buildSearchHeader() {
    final coordinates = new geocoder.Coordinates(
        prefix0.currentUser.location.latitude,
        prefix0.currentUser.location.longitude);

    return Container(
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: MediaQuery.of(context).size.height * 0.25,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.fitWidth,
            child: Text(
              "Hello " + prefix0.currentUser.name + "!",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          FutureBuilder<List<geocoder.Address>>(
              future: geocoder.Geocoder.google(
                      "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI")
                  .findAddressesFromCoordinates(coordinates),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    "Loading...",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white),
                  );
                }
                return RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "Your Set Location: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16)),
                    TextSpan(
                      text: snapshot.data.first.addressLine,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                );
              }),
          SizedBox(
            height: 4,
          ),
          FlatButton.icon(
              icon: Icon(LineIcons.map),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              label: Text("Change"),
              textColor: Colors.white,
              onPressed: () =>
                  Navigator.pushNamed(context, MapScreen.routeName)),
        ],
      ),
    );
  }

  buildEventsList() {
    return Flexible(
      child: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Events Near You",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.pushNamed(
                        context, EventsSearchScreen.routeName,
                        arguments:
                            EventsScreenArguments(eventList: [..._eventList])),
                    child: Text(
                      "See All",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(left: 12, right: 12),
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 16,
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: _eventList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 10,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            width: 250,
                            height: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _eventList[index].title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      child: Text(
                                        _eventList[index].type == 0
                                            ? "Concert"
                                            : _eventList[index].type == 1
                                                ? "Audition"
                                                : "Jam Session",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(_eventList[index].name),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    child: Card(
                                      elevation: 5,
                                      child:
                                          /* GoogleMap(
                                        scrollGesturesEnabled: false,
                                        zoomGesturesEnabled: false,
                                        myLocationButtonEnabled: false,
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              _eventList[index]
                                                  .location
                                                  .latitude,
                                              _eventList[index]
                                                  .location
                                                  .longitude),
                                          zoom: 14.0000,
                                        ),
                                        markers: {
                                          Marker(
                                              markerId:
                                                  MarkerId("Event Location"),
                                              position: LatLng(
                                                  _eventList[index]
                                                      .location
                                                      .latitude,
                                                  _eventList[index]
                                                      .location
                                                      .longitude))
                                        },
                                      ), */
                                          Container(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  _eventList[index].text,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).accentColor)),
                                  child: Text(
                                    DateFormat.yMMMd()
                                        .add_jm()
                                        .format(_eventList[index].time),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  _eventList[index]
                                          .location
                                          .distance(
                                              lat: prefix0.currentUser.location
                                                  .latitude,
                                              lng: prefix0.currentUser.location
                                                  .longitude)
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildUsersList() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Musicians Near You",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                FlatButton(
                  onPressed: () => Navigator.pushNamed(
                      context, MusiciansSearchScreen.routeName,
                      arguments:
                          MusiciansScreenArguments(userList: [..._userList])),
                  child: Text(
                    "See All",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(left: 12, right: 12),
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 16,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: _userList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 134,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, ProfileScreen.routeName,
                        arguments: ProfileScreenArguments(
                            userId: _userList[index].uid)),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 10,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: 134,
                                height: 140,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 45,
                                    ),
                                    Text(
                                      _userList[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      height: 30,
                                      child: FittedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            for (String inst in _userList[index]
                                                .instruments
                                                .keys)
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: Icon(
                                                  Utils.valueToIcon(inst),
                                                  size: 30,
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        _userList[index]
                                                .location
                                                .distance(
                                                    lat: prefix0.currentUser
                                                        .location.latitude,
                                                    lng: prefix0.currentUser
                                                        .location.longitude)
                                                .round()
                                                .toString() +
                                            " km away",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: _userList[index].photoUrl == null
                              ? AssetImage("assets/images/user-placeholder.png")
                              : CachedNetworkImageProvider(
                                  _userList[index].photoUrl),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  buildMainArea() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      height: 700,
      width: double.infinity,
      child: _isLoading
          ? circularProgress(context)
          : Column(
              children: <Widget>[
                buildUsersList(),
                buildEventsList(),
              ],
            ),
    );
  }
}
