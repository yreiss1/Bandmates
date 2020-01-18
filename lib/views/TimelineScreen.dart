import 'dart:async';

import 'package:bandmates/models/Event.dart';
import 'package:bandmates/views/EventsSearchScreen.dart';
import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/MusiciansSearchScreen.dart';
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
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
import 'package:provider/provider.dart';
import '../Utils.dart';

import '../models/User.dart';

final usersRef = Firestore.instance.collection('users');

class TimelineScreen extends StatelessWidget {
  final User currentUser;

  TimelineScreen({this.currentUser});

  final GeoFirePoint center = prefix0.currentUser.location;

  @override
  Widget build(BuildContext context) {
    print("[Timeline] Rebuilding the widget");

    return ListView(
      children: <Widget>[
        buildSearchHeader(context),
        buildMainArea(context),
      ],
    );
  }

  buildSearchHeader(context) {
    final coordinates = new geocoder.Coordinates(
        prefix0.currentUser.location.latitude,
        prefix0.currentUser.location.longitude);

    return Container(
      padding: EdgeInsets.only(left: 12, top: 24, right: 12),
      height: MediaQuery.of(context).size.height * 0.3,
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
            height: 16,
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
                        text: "Your Location: ",
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  paramFunction: changeLocation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  changeLocation(LatLng setLocation) {
    GeoFirePoint point =
        GeoFirePoint(setLocation.latitude, setLocation.longitude);
    print("[MapScreen] " + point.data.toString());

    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .updateData({
      'location': point.data,
    });
    currentUser.location = point;
  }

  buildEventsList(context) {
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
                      context,
                      EventsSearchScreen.routeName,
                    ),
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
            StreamBuilder<List<DocumentSnapshot>>(
              stream: Provider.of<EventProvider>(context).getClosest(center),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: circularProgress(context),
                  );
                }

                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text("There are no events currently in your area"),
                  );
                }

                if (snapshot.error != null) {
                  return Center(
                    child: Text(
                      "There was an error fetching events, please try again later",
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 16,
                      );
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Event event = Event.fromDocument(snapshot.data[index]);
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            event.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          child: Text(
                                            event.type == 0
                                                ? "Concert"
                                                : event.type == 1
                                                    ? "Audition"
                                                    : event.type == 2
                                                        ? "Jam Session"
                                                        : "Open Mic",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      event.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      height: 100,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        child: Card(
                                          semanticContainer: true,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          elevation: 10,
                                          child: event.photoUrl != null
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              event.photoUrl),
                                                    ),
                                                  ),
                                                )
                                              :
                                              /* GoogleMap(
                                        scrollGesturesEnabled: false,
                                        zoomGesturesEnabled: false,
                                        myLocationButtonEnabled: false,
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              event
                                                  .location
                                                  .latitude,
                                              event
                                                  .location
                                                  .longitude),
                                          zoom: 14.0000,
                                        ),
                                        markers: {
                                          Marker(
                                              markerId:
                                                  MarkerId("Event Location"),
                                              position: LatLng(
                                                  event
                                                      .location
                                                      .latitude,
                                                  event
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
                                      event.text,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .accentColor)),
                                      child: Text(
                                        DateFormat.yMMMd()
                                            .add_jm()
                                            .format(event.time),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      event.location
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
                );
              },
            )
          ],
        ),
      ),
    );
  }

  buildUsersList(context) {
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
                    context,
                    MusiciansSearchScreen.routeName,
                  ),
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
          StreamBuilder(
            stream: Provider.of<UserProvider>(context).getClosest(center),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: circularProgress(context),
                );
              }

              if (snapshot.data.length == 0) {
                return Center(
                  child: Text("There are no users currently in your area"),
                );
              }

              if (snapshot.error != null) {
                return Center(
                  child: Text(
                    "There was an error fetching data, please try again later",
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 16,
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = User.fromDocument(snapshot.data[index]);
                    if (user.uid == prefix0.currentUser.uid) {
                      return Container();
                    }
                    return Container(
                      width: 134,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, ProfileScreen.routeName,
                            arguments:
                                ProfileScreenArguments(userId: user.uid)),
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
                                          user.name,
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
                                                for (String inst
                                                    in user.instruments.keys)
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
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
                                            user.location
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
                              backgroundImage: user.photoUrl == null
                                  ? AssetImage(
                                      "assets/images/user-placeholder.png")
                                  : CachedNetworkImageProvider(user.photoUrl),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      height: 700,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          buildUsersList(context),
          buildEventsList(context),
        ],
      ),
    );
  }
}
