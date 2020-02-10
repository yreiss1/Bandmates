import 'package:bandmates/models/Classified.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:map_launcher/map_launcher.dart' as mapLauncher;

import '../Utils.dart';

class ClassifiedScreen extends StatelessWidget {
  final Classified classified;
  ClassifiedScreen({this.classified});

  _openMapSheet(context) async {
    try {
      final title = classified.title;
      final description = classified.text;
      final coords = mapLauncher.Coords(
          classified.location.latitude, classified.location.longitude);
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
              onRefresh: () {}, //=> _getAttendees(),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    forceElevated: false,
                    actions: <Widget>[],
                    title: Text(
                      classified.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildClassifiedCard(context),
                  ),
                  // SliverToBoxAdapter(
                  //   child: _buildAttendingList(context),
                  // ),
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

  _buildClassifiedCard(context) {
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
                Container(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Card(
                      elevation: 5,
                      child: GoogleMap(
                        onTap: (_) => _openMapSheet(context),
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        buildingsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(classified.location.coords.latitude,
                              classified.location.coords.longitude),
                          zoom: 12.0000,
                        ),
                        markers: {
                          Marker(
                              infoWindow: InfoWindow(
                                title: classified.title,
                                /*snippet: event.type.toString()*/
                              ),
                              markerId: MarkerId(classified.title),
                              position: LatLng(
                                  classified.location.coords.latitude,
                                  classified.location.coords.longitude))
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
                                          classified.location.coords.latitude,
                                          classified
                                              .location.coords.longitude)),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
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
                              classified.title,
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
                              Utils.deserializeEventType(classified.type),
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
                        "Hosted By: " + classified.username,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        classified.text,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
