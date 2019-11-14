import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:jammerz/views/UI/Header.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import 'package:geoflutterfire/geoflutterfire.dart';
import '../../Utils.dart';
import '../../models/user.dart';
import 'dart:async';

import '../UI/InstrumentChipInput.dart';

class EventUploadScreen extends StatefulWidget {
  static const routeName = '/event-upload';

  @override
  _EventUploadScreenState createState() => _EventUploadScreenState();
}

class _EventUploadScreenState extends State<EventUploadScreen> {
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  TextEditingController locationController = new TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();
  Location location = new Location();
  Set<Marker> markers = Set();
  GeoFirePoint point;
  Geoflutterfire geo = Geoflutterfire();
  bool _isAudition = false;

  CameraPosition _initialCamera;
  @override
  void initState() {
    super.initState();
    User user = Utils.getUser();

    _initialCamera = user == null || user.location == null
        ? CameraPosition(
            target: LatLng(38.9072, -77.0369),
            zoom: 14.0000,
          )
        : CameraPosition(
            target: LatLng(
                user.location.coords.latitude, user.location.coords.latitude),
            zoom: 14.0000,
          );
  }

  Future<LocationData> _getLocation() async {
    var pos = await location.getLocation();
    setState(() {
      point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    });
    final coordinates = new prefix1.Coordinates(pos.latitude, pos.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = address.first;

    print(
        "${first.featureName} : ${first.addressLine} : ${first.subLocality} : ${first.subThoroughfare} : ${first.subAdminArea}");
    locationController.text = first.subAdminArea;
    markers.clear();
    markers.add(Marker(
        consumeTapEvents: true,
        infoWindow: InfoWindow(
          title: "My Location",
        ),
        markerId: MarkerId("My Location"),
        position: LatLng(pos.latitude, pos.longitude)));
    GoogleMapController controller = await _mapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(pos.latitude, pos.longitude), zoom: 14.0000)));
  }

  @override
  void dispose() {
    //locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: uploadHeader("Upload Event", context, fbKey),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * .45
                  : MediaQuery.of(context).size.height * .55,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCamera,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    markers: markers,
                  ),
                  Positioned(
                    top: 10,
                    left: MediaQuery.of(context).size.width * 0.04,
                    right: MediaQuery.of(context).size.width * 0.04,
                    child: Container(
                      height: 60,
                      child: SearchMapPlaceWidget(
                        apiKey: "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI",
                        location: _initialCamera.target,
                        radius: 30000,
                        onSelected: (place) async {
                          final geolocation = await place.geolocation;
                          markers.clear();
                          markers.add(Marker(
                              markerId: MarkerId("Event Venue"),
                              position: geolocation.coordinates));

                          final GoogleMapController controller =
                              await _mapController.future;

                          controller.animateCamera(
                              CameraUpdate.newLatLng(geolocation.coordinates));
                          controller.animateCamera(CameraUpdate.newLatLngBounds(
                              geolocation.bounds, 0));
                          LatLng latLng = geolocation.coordinates;
                          var coordinates = new prefix1.Coordinates(
                              latLng.latitude, latLng.longitude);
                          var addressses = await Geocoder.local
                              .findAddressesFromCoordinates(coordinates);
                          locationController.text =
                              addressses.first.addressLine;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FormBuilder(
              autovalidate: false,
              key: fbKey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "My event is a ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .6,
                        child: FormBuilderDropdown(
                          onChanged: (event) {
                            if (event == "Audition") {
                              setState(() {
                                _isAudition = true;
                              });
                            } else {
                              setState(() {
                                _isAudition = false;
                              });
                            }
                          },
                          attribute: "event",
                          decoration: InputDecoration(labelText: "Event Type"),
                          // initialValue: 'Male',
                          hint: Text('Select Event'),
                          validators: [FormBuilderValidators.required()],
                          items: ['Concert', 'Audition', 'Jam Session']
                              .map((event) => DropdownMenuItem(
                                  value: event, child: Text("$event")))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .80,
                        child: FormBuilderTextField(
                          attribute: 'location',
                          decoration: InputDecoration(
                            labelText: "Your location",
                          ),
                          readOnly: false,
                          controller: locationController,
                          validators: [FormBuilderValidators.required()],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FloatingActionButton(
                        mini: true,
                        elevation: 0,
                        child: Icon(LineIcons.crosshairs),
                        onPressed: () => _getLocation(),
                      )
                    ],
                  ),
                  if (_isAudition) ...[
                    SizedBox(
                      height: 10,
                    ),
                    InstrumentChipInput(
                      fbKey: fbKey,
                      label: "Instruments to Audition",
                      maxChips: 4,
                    ),
                  ],
                  FormBuilderTextField(
                    attribute: "description",
                    decoration: InputDecoration(
                      labelText: "Event Description",
                      hintText: 'Tell us about your event',
                    ),
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
