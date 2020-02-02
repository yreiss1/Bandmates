import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';
  final Function paramFunction;

  final LatLng currentLocation;
  final bool isEvent;

  MapScreen(
      {@required this.paramFunction,
      @required this.currentLocation,
      @required this.isEvent});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var location = new Location();
  Completer<GoogleMapController> _mapController = Completer();

  LocationData _currentLocation;
  CameraPosition _initialCamera;
  Set<Circle> circles;
  Set<Marker> markers;

  LatLng _setLocation;
  @override
  void initState() {
    super.initState();
    _setLocation = LatLng(
        widget.currentLocation.latitude, widget.currentLocation.longitude);
    _initialCamera = CameraPosition(
        target: LatLng(
            widget.currentLocation.latitude, widget.currentLocation.longitude),
        zoom: 12);

    if (widget.isEvent) {
      markers = Set<Marker>();
      markers.add(Marker(
          markerId: MarkerId('Event Location'),
          position: LatLng(widget.currentLocation.latitude,
              widget.currentLocation.longitude)));
    } else {
      circles = Set<Circle>();

      circles.add(
        Circle(
          strokeWidth: 1,
          radius: 1500,
          fillColor: Color(0xff53172c).withOpacity(0.4),
          circleId: CircleId("Set Location"),
          center: LatLng(widget.currentLocation.latitude,
              widget.currentLocation.longitude),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getCurrentLocation() async {
    try {
      _currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        AlertDialog(
          content: Text(
              "Enable location permissions for this app in phone settings"),
          actions: <Widget>[
            DialogButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }

      _currentLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (latlng) async {
              final GoogleMapController controller =
                  await _mapController.future;

              // List<geocoder.Address> list = await geocoder.Geocoder.google(
              //         "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI")
              //     .findAddressesFromCoordinates(new geocoder.Coordinates(
              //         latlng.latitude, latlng.longitude));

              controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: latlng, zoom: 12)));

              controller.animateCamera(CameraUpdate.newLatLngZoom(latlng, 12));
              setState(() {
                _setLocation = latlng;
                if (widget.isEvent) {
                  markers.clear();
                  markers.add(
                    Marker(
                        markerId: MarkerId('Event Location'),
                        position: latlng,
                        infoWindow: InfoWindow(title: "Event Location"),
                        visible: true),
                  );
                } else {
                  circles.clear();
                  circles.add(
                    Circle(
                        strokeWidth: 1,
                        radius: 1750,
                        fillColor:
                            Theme.of(context).primaryColor.withOpacity(0.4),
                        circleId: CircleId("Your Location"),
                        center: latlng),
                  );
                }
              });
            },
            myLocationEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(12, 12),
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            circles: circles,
            markers: markers,
          ),
          Positioned(
            top: 50,
            left: 5,
            child: IconButton(
              icon: Icon(
                Icons.clear,
                size: 32,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.15,
            right: MediaQuery.of(context).size.width * 0.04,
            child: Center(
              child: SearchMapPlaceWidget(
                apiKey: "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI",
                location: _initialCamera.target,
                radius: 30000,
                placeholder: "Set Your Home Location",
                onSelected: (place) async {
                  final geolocation = await place.geolocation;
                  setState(() {
                    if (widget.isEvent) {
                      markers.clear();
                      markers.add(
                        Marker(
                            markerId: MarkerId('Event Location'),
                            position: geolocation.coordinates,
                            infoWindow: InfoWindow(title: 'Event Location')),
                      );
                    } else {
                      circles.clear();
                      circles.add(
                        Circle(
                            strokeWidth: 1,
                            radius: 1750,
                            fillColor:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            circleId: CircleId("Your Location"),
                            center: geolocation.coordinates),
                      );
                    }
                  });

                  final GoogleMapController controller =
                      await _mapController.future;

                  controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: geolocation.coordinates, zoom: 12)));

                  controller.animateCamera(
                      CameraUpdate.newLatLngZoom(geolocation.coordinates, 12));

                  controller.animateCamera(
                      CameraUpdate.newLatLngBounds(geolocation.bounds, 50));

                  setState(() {
                    _setLocation = geolocation.coordinates;
                  });
                },
              ),
            ),
          ),
          Positioned.fill(
            bottom: 45,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                icon: Icon(Icons.check),
                label: Text("Save Location"),
                onPressed: () {
                  widget.paramFunction(_setLocation);
                  Navigator.pop(context);
                },
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
