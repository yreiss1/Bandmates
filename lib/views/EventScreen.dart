import 'package:bandmates/models/Attending.dart';
import 'package:bandmates/models/Event.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:provider/provider.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauncher;

import '../Utils.dart';

class EventScreen extends StatefulWidget {
  final Event event;
  EventScreen({this.event});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  DocumentSnapshot _lastDocument;

  bool _isLoading = false;
  List<Attending> _attendingList = [];
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.2;

      if (maxScroll - currentScroll <= delta) {
        _getAttendees();
      }
    });

    _getAttendees();
  }

  _getAttendees() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot snapshot;
    if (_lastDocument == null) {
      snapshot = await Firestore.instance
          .collection("attending")
          .document(widget.event.eventId)
          .collection("attending")
          .orderBy('loc.geohash')
          .limit(20)
          .getDocuments();
    } else {
      snapshot = await Firestore.instance
          .collection("attending")
          .document(widget.event.eventId)
          .collection("attending")
          .startAfterDocument(_lastDocument)
          .orderBy('loc.geohash')
          .limit(20)
          .getDocuments();
    }

    if (!snapshot.documents.isEmpty) {
      _lastDocument = snapshot.documents[snapshot.documents.length - 1];
    }
    List<Attending> results = [];
    snapshot.documents
        .forEach((doc) => results.add(Attending.fromDocument(doc)));

    if (_attendingList.any((attendee) => attendee.userId == currentUser.uid)) {
      results.removeWhere((attendee) => attendee.userId == currentUser.uid);
    }

    setState(() {
      _attendingList.addAll(results);
      // _attendingList.sort((a1, a2) {
      //   return a1.location.distance(lat: a2.location.latitude, lng: a2.location.longitude).round();
      // });
      _isLoading = false;
    });
  }

  Future<bool> _onAttendingButtonTapped(bool isLiked) async {
    if (!isLiked) {
      await Firestore.instance
          .collection("attending")
          .document(widget.event.eventId)
          .collection('attending')
          .document(currentUser.uid)
          .setData({
        'name': currentUser.name,
        'avatar': currentUser.photoUrl,
        'loc': currentUser.location.data
      }).then((result) {
        setState(() {
          _attendingList.add(Attending(
            avatar: currentUser.photoUrl,
            userId: currentUser.uid,
            username: currentUser.name,
            location: currentUser.location,
          ));
        });
      }).catchError((error) {
        Utils.buildErrorDialog(context, "Could not attend this event");
      });
    } else {
      await Firestore.instance
          .collection("attending")
          .document(widget.event.eventId)
          .collection('attending')
          .document(currentUser.uid)
          .delete()
          .then((result) {
        setState(() {
          _attendingList
              .removeWhere((attendee) => attendee.userId == currentUser.uid);
        });
      }).catchError((error) {
        Utils.buildErrorDialog(
            context, "Unable to connect to database, please try again later!");
      });
    }

    return !isLiked;
  }

  _openMapSheet() async {
    try {
      final title = widget.event.title;
      final description = widget.event.text;
      final coords = mapLauncher.Coords(
          widget.event.location.latitude, widget.event.location.longitude);
      final availableMaps = await mapLauncher.MapLauncher.installedMaps;

      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Wrap(
                    children: <Widget>[
                      for (var map in availableMaps)
                        ListTile(
                          onTap: () => map.showMarker(
                            coords: coords,
                            title: title,
                            description: description,
                          ),
                          title: Text(map.mapName),
                          leading: Image(
                            image: map.icon,
                            height: 30.0,
                            width: 30.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: <Widget>[
            _buildHeader(context),
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () => _getAttendees(),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    forceElevated: false,
                    actions: <Widget>[],
                    title: Text(
                      widget.event.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildEventCard(context),
                  ),
                  SliverToBoxAdapter(
                    child: _buildAttendingList(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildHeader(context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 32),
      height: 250,
      width: double.infinity,
      child: Container(),
    );
  }

  _buildEventCard(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Container(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Card(
                  elevation: 5,
                  child: GoogleMap(
                    onTap: (_) => _openMapSheet(),
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    buildingsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.event.location.coords.latitude,
                          widget.event.location.coords.longitude),
                      zoom: 12.0000,
                    ),
                    markers: {
                      Marker(
                          infoWindow: InfoWindow(
                            title: widget.event.title,
                            /*snippet: event.type.toString()*/
                          ),
                          markerId: MarkerId(widget.event.title),
                          position: LatLng(
                              widget.event.location.coords.latitude,
                              widget.event.location.coords.longitude))
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        LineIcons.map_marker,
                        color: Theme.of(context).primaryColor,
                      ),
                      Flexible(
                        child: FutureBuilder<List<geocoder.Address>>(
                          future: geocoder.Geocoder.google(
                                  "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI")
                              .findAddressesFromCoordinates(
                                  geocoder.Coordinates(
                                      widget.event.location.coords.latitude,
                                      widget.event.location.coords.longitude)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text("Loading...");
                            }

                            if (snapshot.hasError) {
                              return Text(
                                "Error: " + snapshot.error,
                                overflow: TextOverflow.ellipsis,
                              );
                            }

                            return Text(
                              snapshot.data.first.addressLine,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.event.title,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor)),
                        child: Text(
                          Utils.deserializeEventType(widget.event.type),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Hosted By: " + widget.event.name,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.event.text,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  if (widget.event.audition != null &&
                      widget.event.audition.isNotEmpty &&
                      widget.event.type == 1)
                    Column(
                      children: <Widget>[
                        Text(
                          "Instruments to Audition",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            runSpacing: 0,
                            spacing: 4,
                            children: [
                              for (String audition in widget.event.audition)
                                Chip(
                                  label: Text(audition),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (widget.event.genres != null &&
                      widget.event.genres.isNotEmpty)
                    Column(
                      children: <Widget>[
                        Divider(),
                        Text(
                          "Genres",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            runSpacing: 0,
                            spacing: 4,
                            children: [
                              for (String genre in widget.event.genres)
                                Chip(
                                  label: Text(genre),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).accentColor)),
                        child: FittedBox(
                          child: Text(
                            widget.event.end == null
                                ? DateFormat.jm()
                                    .add_yMMMd()
                                    .format(widget.event.start)
                                : Utils.formateDateTime(
                                    widget.event.start, widget.event.end),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: Provider.of<EventProvider>(context)
                            .getAttending(widget.event.eventId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.hasError) {
                            return LikeButton(
                                size: 36,
                                circleColor: CircleColor(
                                    start: Theme.of(context).accentColor,
                                    end: Theme.of(context).primaryColor),
                                bubblesColor: BubblesColor(
                                    dotPrimaryColor:
                                        Theme.of(context).primaryColor,
                                    dotSecondaryColor:
                                        Theme.of(context).accentColor),
                                likeBuilder: (bool isLiked) {
                                  return Icon(
                                    LineIcons.thumbs_up,
                                    size: 36,
                                    color: isLiked
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  );
                                },
                                isLiked: snapshot.data.documents.any(
                                    (doc) => doc.documentID == currentUser.uid),
                                likeCount: snapshot.data.documents.length,
                                countPostion: CountPostion.left,
                                countBuilder:
                                    (int count, bool isLiked, String text) {
                                  Widget result;
                                  if (count == 0) {
                                    result = Text("Attend");
                                  } else {
                                    result = Text(
                                      count >= 1000
                                          ? (count / 1000.0)
                                                  .toStringAsFixed(1) +
                                              "k"
                                          : text,
                                    );
                                  }

                                  return result;
                                },
                                likeCountAnimationType:
                                    snapshot.data.documents.length < 1000
                                        ? LikeCountAnimationType.part
                                        : LikeCountAnimationType.none,
                                onTap: _onAttendingButtonTapped);
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  _buildAttendingList(context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Attending",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              _attendingList.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: Text("No one attending yet, be the first!"),
                      ),
                    )
                  : Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _attendingList.length,
                        itemBuilder: (context, index) {
                          return _attendingList[index];
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
