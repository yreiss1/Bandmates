import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/DiscoverScreenArguments.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import '../views/UI/ProfileScreenBody.dart';

import 'package:location/location.dart';
import 'dart:async';

import 'package:geoflutterfire/geoflutterfire.dart';

class DiscoverScreen extends StatefulWidget {
  static final String routeName = '/discovery-screen';

  final DiscoverScreenArguments searchParams;

  DiscoverScreen(this.searchParams);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  Location location = new Location();
  Future<List<User>> _data;

  Future<List<User>> getUsers() async {
    List<User> results = [];
    Geoflutterfire geo = Geoflutterfire();

    Instrument instrument = widget.searchParams.instrument;
    bool transportation = widget.searchParams.transportation;
    bool practiceSpace = widget.searchParams.practiceSpace;
    double rad = widget.searchParams.radius;

    LocationData loc = await location.getLocation();
    GeoFirePoint myPoint =
        geo.point(latitude: loc.latitude, longitude: loc.longitude);

    CollectionReference userRef = Firestore.instance.collection("users");
    await userRef
        .where("transport", isEqualTo: transportation)
        .where("practice", isEqualTo: practiceSpace)
        .where("instruments.${instrument.value}", isEqualTo: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) {
        User user = User.fromDocument(doc);

        if (myPoint.distance(
                lat: user.location.coords.latitude,
                lng: user.location.coords.longitude) <=
            rad) {
          results.add(user);
        }
      });
    });

    print("[DiscoverScreen] results: " + results.toString());
    return results;
  }

  @override
  void initState() {
    super.initState();
    _data = getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFF1d1e2c)),
          leading: IconButton(
            icon: Icon(LineIcons.arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            "Discover",
            style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
          ),
        ),
        body: FutureBuilder(
          future: _data,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Container(
                  child: Center(
                    child: Text("Error:" + snapshot.error.toString()),
                  ),
                );
              }
              if (snapshot.hasData) {
                return snapshot.data.length == 0
                    ? Center(
                        child: Text("No results!"),
                      )
                    : Swiper(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ProfileScreenBody(user: snapshot.data[index]);
                        },
                      );
              } else {
                return circularProgress(context);
              }
            } else if (snapshot.connectionState == ConnectionState.active) {
              return circularProgress(context);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } else {
              return circularProgress(context);
            }
          },
        ));
  }
}
