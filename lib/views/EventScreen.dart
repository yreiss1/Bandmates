import 'package:bandmates/models/Attending.dart';
import 'package:bandmates/models/Event.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:provider/provider.dart';

import '../Utils.dart';

class EventScreen extends StatelessWidget {
  final Event event;
  EventScreen({this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: <Widget>[
            _buildHeader(context),
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  forceElevated: false,
                  actions: <Widget>[],
                  title: Text(
                    event.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                      [_buildEventCard(context), _buildAttendingList(context)]),
                ),
              ],
            )
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                event.photoUrl != null
                    ? Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          child: customNetworkImage(event.photoUrl),
                        ),
                      )
                    : Container(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: Card(
                            elevation: 5,
                            child: GoogleMap(
                              scrollGesturesEnabled: true,
                              zoomGesturesEnabled: true,
                              myLocationButtonEnabled: false,
                              buildingsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(event.location.coords.latitude,
                                    event.location.coords.longitude),
                                zoom: 12.0000,
                              ),
                              markers: {
                                Marker(
                                    infoWindow: InfoWindow(
                                      title: event.title,
                                      /*snippet: event.type.toString()*/
                                    ),
                                    markerId: MarkerId(event.title),
                                    position: LatLng(
                                        event.location.coords.latitude,
                                        event.location.coords.longitude))
                              },
                            ),
                          ),
                        ),
                      ),
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
                            .findAddressesFromCoordinates(geocoder.Coordinates(
                                event.location.coords.latitude,
                                event.location.coords.longitude)),
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
                    Text(
                      event.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor)),
                      child: Text(
                        Utils.deserializeEventType(event.type),
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
                  "Hosted By: " + event.name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  event.text,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                if (event.audition != null &&
                    event.audition.isNotEmpty &&
                    event.type == 1)
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
                            for (String audition in event.audition)
                              Chip(
                                label: Text(audition),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                if (event.genres != null && event.genres.isNotEmpty)
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
                            for (String genre in event.genres)
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
                          border:
                              Border.all(color: Theme.of(context).accentColor)),
                      child: Text(
                        DateFormat.yMMMd().add_jm().format(event.time),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LineIcons.thumbs_up,
                        size: 32,
                      ),
                      onPressed: () => print("Attending!"),
                    )
                  ],
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
          child: StreamBuilder<QuerySnapshot>(
            stream:
                Provider.of<EventProvider>(context).getAttending(event.eventId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: circularProgress(context),
                );
              }

              if (snapshot.hasError) {
                Utils.buildErrorDialog(context,
                    "Cannot obtain attending list, please try again soon!");
              }

              if (snapshot.data.documents.isEmpty) {
                return Center(
                  child: Text("No attendees currently"),
                );
              }
              List<Attending> attending = [];

              snapshot.data.documents.forEach((doc) {
                attending.add(Attending.fromDocument(doc));
              });

              return Column(
                  mainAxisSize: MainAxisSize.min, children: attending);
            },
          ),
        ),
      ),
    );
  }
}
