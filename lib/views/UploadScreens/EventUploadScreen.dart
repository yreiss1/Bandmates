import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:bandmates/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bandmates/models/Event.dart';
import 'package:intl/intl.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';
import '../../models/User.dart';
import '../../models/Event.dart';
import 'package:uuid/uuid.dart';
import '../../models/Instrument.dart';

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
  bool _isUploading = false;
  int index = 0;
  String _eventID = Uuid().v4();

  FocusNode _textFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();

  CameraPosition _initialCamera;
  @override
  void initState() {
    super.initState();

    _initialCamera = CameraPosition(
      target: LatLng(38.9072, -77.0369),
      zoom: 14.0000,
    );
  }

  Future<LocationData> _getLocation() async {
    var pos = await Provider.of<UserProvider>(context).getUserLocation();
    setState(() {
      point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    });
    final coordinates = new prefix1.Coordinates(pos.latitude, pos.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = address.first;

    print(
        "[EventUploadScreen] ${first.featureName} : ${first.addressLine} : ${first.subLocality} : ${first.subThoroughfare} : ${first.subAdminArea}");
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
    _locationFocusNode.dispose();
    _textFocusNode.dispose();
    _timeFocusNode.dispose();

    super.dispose();
  }

  List<Instrument> searchInstruments(String query) {
    List<Instrument> results = [];
    for (Instrument instrument in instruments) {
      if (instrument.instrumentName.contains(query.toLowerCase()) ||
          query.toLowerCase().contains(instrument.instrumentName)) {
        results.add(instrument);
      }
    }

    return results;
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isUploading = true;
      });

      var user = Provider.of<FirebaseUser>(context, listen: false);
      User userObject = await Provider.of<UserProvider>(context, listen: false)
          .getUser(user.uid);

      int type;
      switch (fbKey.currentState.value['event']) {
        case "Concert":
          {
            type = 1;
          }
          break;
        case "Audition":
          {
            type = 2;
          }
          break;
        case "Jam Session":
          {
            type = 3;
          }
          break;
      }

      Map<String, bool> audition = _isAudition == false
          ? null
          : Map.fromIterable(fbKey.currentState.value['audition'],
              key: (k) => k.value, value: (v) => true);
      Event event = new Event(
        text: fbKey.currentState.value['text'],
        location: point,
        type: type,
        time: fbKey.currentState.value['datetime'],
        audition: audition,
      );
      await Provider.of<EventProvider>(context)
          .uploadEvent(event, _eventID, user.uid, userObject.name);

      setState(() {
        _isUploading = false;
        point = null;
      });
      Navigator.pop(context);
    }
  }

  AppBar uploadHeader(String text, BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        text,
        style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
      ),
      leading: IconButton(
        icon: Icon(
          LineIcons.arrow_left,
          color: Color(0xFF1d1e2c),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            LineIcons.check,
            color: Color(0xFF1d1e2c),
            size: 30,
          ),
          onPressed: _isUploading ? null : () => _handleSubmit(),
        )
      ],
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    var pos = Provider.of<UserProvider>(context).getUserLocation();
    if (pos != null) {
      _initialCamera = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14.0000,
      );
    }
    return SafeArea(
      child: Scaffold(
        appBar: uploadHeader("Upload Event", context),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            _isUploading ? linearProgress(context) : Container(),
            Container(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * .40
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
                    child: SearchMapPlaceWidget(
                      apiKey: "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI",
                      location: _initialCamera.target,
                      radius: 30000,
                      onSelected: (place) async {
                        final geolocation = await place.geolocation;
                        setState(() {
                          markers.clear();
                          markers.add(Marker(
                              markerId: MarkerId("Event Venue"),
                              infoWindow: InfoWindow(
                                  title: "Event Venue",
                                  snippet:
                                      "This is where your event will take place"),
                              position: geolocation.coordinates));
                        });

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
                        locationController.text = addressses.first.addressLine;
                        point = GeoFirePoint(latLng.latitude, latLng.longitude);
                      },
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Event Type: ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .65,
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
                  if (_isAudition) ...[
                    SizedBox(
                      height: 10,
                    ),
                    FormBuilderChipsInput(
                      inputType: TextInputType.text,
                      obscureText: false,
                      autocorrect: false,
                      keyboardAppearance: Brightness.light,
                      textCapitalization: TextCapitalization.none,
                      inputAction: TextInputAction.next,
                      decoration:
                          InputDecoration(labelText: "Insruments to Audition"),
                      attribute: 'audition',
                      findSuggestions: (query) => searchInstruments(query),
                      maxChips: 3,
                      validators: [FormBuilderValidators.required()],
                      suggestionsBoxMaxHeight: 200,
                      chipBuilder: (context, state, profile) {
                        return InputChip(
                          key: ObjectKey(profile),
                          label: Text(profile.instrumentName),
                          onDeleted: () => state.deleteChip(profile),
                          avatar: profile.instrumentIcon,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                      suggestionBuilder: (context, state, profile) {
                        return ListTile(
                          key: ObjectKey(profile),
                          leading: profile.instrumentIcon,
                          title: Text(profile.instrumentName),
                          onTap: () => state.selectSuggestion(profile),
                        );
                      },
                    ),
                  ],
                  SizedBox(
                    height: 10,
                  ),
                  FormBuilderDateTimePicker(
                    focusNode: _timeFocusNode,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_locationFocusNode),
                    attribute: 'datetime',
                    inputType: InputType.both,
                    format: DateFormat("EEE, MMM d, 'at' hh:mm aaa"),
                    decoration: InputDecoration(labelText: "Time of Event"),
                    cursorColor: Theme.of(context).primaryColor,
                    enabled: true,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 7)),
                    lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                    validators: [FormBuilderValidators.required()],
                    readOnly: false,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
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
                          focusNode: _locationFocusNode,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_textFocusNode),
                          attribute: 'location',
                          decoration: InputDecoration(
                            labelText: "Event location",
                          ),
                          readOnly: false,
                          controller: locationController,
                          textInputAction: TextInputAction.next,
                          validators: [FormBuilderValidators.required()],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FloatingActionButton(
                        mini: true,
                        elevation: 0,
                        child: Icon(LineIcons.crosshairs),
                        onPressed: () => _getLocation(),
                      )
                    ],
                  ),
                  FormBuilderTextField(
                    focusNode: _textFocusNode,
                    attribute: 'text',
                    decoration: InputDecoration(
                      labelText: "Event Description",
                      hintText: 'Tell us about your event',
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
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
