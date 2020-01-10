import 'dart:io';

import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/UI/InstrumentChipInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:bandmates/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bandmates/models/Event.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';
import '../../Utils.dart';
import '../../models/User.dart';
import '../../models/Event.dart';
import 'package:uuid/uuid.dart';
import '../../models/Instrument.dart';

import 'dart:async';

class EventUploadScreen extends StatefulWidget {
  static const routeName = '/event-upload';

  @override
  _EventUploadScreenState createState() => _EventUploadScreenState();
}

class _EventUploadScreenState extends State<EventUploadScreen> {
  GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();
  TextEditingController locationController = new TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();
  Location location = new Location();
  Set<Marker> markers = Set();
  GeoFirePoint point;
  Geoflutterfire geo = Geoflutterfire();
  bool _isAudition = false;
  bool _isUploading = false;
  File _imageFile;
  int index = 0;
  String _eventID = Uuid().v4();

  FocusNode _titleFocusNode = FocusNode();
  FocusNode _textFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();

  int _eventType;

  CameraPosition _initialCamera;
  @override
  void initState() {
    super.initState();
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
    _titleFocusNode.dispose();
    super.dispose();
  }

  List<Instrument> searchInstruments(String query) {
    List<Instrument> results = [];
    for (Instrument instrument in instruments) {
      if (instrument.instrumentName
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          query
              .toLowerCase()
              .contains(instrument.instrumentName.toLowerCase())) {
        results.add(instrument);
      }
    }

    return results;
  }

  List<Genre> searchGenres(String query) {
    List<Genre> results = [];

    for (Genre genre in Utils.genresList) {
      print(genre.genreName + " " + query.toLowerCase());
      if (genre.genreName.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(genre.genreName.toLowerCase())) {
        results.add(genre);
      }
    }

    return results;
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (point == null) {
      //TODO: Show message that says that location must not be null!!
    }

    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isUploading = true;
      });

      if (_imageFile != null) {}

      Map<String, bool> audition = _isAudition == false
          ? null
          : Map.fromIterable(_fbKey.currentState.value['audition'],
              key: (k) => k.value, value: (v) => true);

      Event event = new Event(
        name: currentUser.name,
        ownerId: currentUser.uid,
        eventId: _eventID,
        title: _fbKey.currentState.value['title'],
        text: _fbKey.currentState.value['text'],
        location: point,
        type: _eventType,
        time: _fbKey.currentState.value['event-time'],
        audition: audition,
      );
      await Provider.of<EventProvider>(context).uploadEvent(event);

      setState(() {
        _isUploading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: <Widget>[
            Scaffold(
              body: Stack(
                children: <Widget>[
                  buildHeader(),
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        forceElevated: false,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 32,
                              color: Colors.white,
                            ),
                            onPressed: () => _handleSubmit(),
                          ),
                        ],
                        expandedHeight: 100,
                        title: Text(
                          "Create Event",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SliverFillRemaining(
                        fillOverscroll: false,
                        hasScrollBody: false,
                        child: _buildEventUploadCard(),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(60),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              bottom: 40,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton.extended(
                  icon: Icon(Icons.add),
                  label: Text("Create Event"),
                  onPressed: () => _handleSubmit(),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: 350,
      width: double.infinity,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }

  _buildEventUploadCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                      height: 180,
                      width: double.infinity,
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.image,
                                  size: 32,
                                ),
                                Text("Upload an Event Image"),
                              ],
                            )
                          : Container(
                              width: 180,
                              height: 180,
                              decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _imageFile != null
                                        ? FileImage(_imageFile)
                                        : AssetImage(
                                            'assets/images/user-placeholder.png')),
                              ),
                            )),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              _imageFile != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          color: Theme.of(context).primaryColor,
                          icon: Icon(LineIcons.crop),
                          textColor: Colors.white,
                          label: Text("Crop"),
                          onPressed: () => _cropImage(),
                        ),
                        FlatButton.icon(
                          icon: Icon(LineIcons.refresh),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          label: Text("Redo"),
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () => _clear(),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton.icon(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          color: Theme.of(context).primaryColor,
                          icon: Icon(LineIcons.camera),
                          textColor: Colors.white,
                          label: Text("Camera"),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        FlatButton.icon(
                          icon: Icon(LineIcons.file_photo_o),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          label: Text("Gallery"),
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
              SizedBox(
                height: 24,
              ),
              FormBuilder(
                key: _fbKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _titleFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_textFocusNode),
                      decoration: new InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Event Title",
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      focusNode: _textFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_timeFocusNode),
                      maxLines: null,
                      decoration: new InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Event Description",
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FormBuilderDateTimePicker(
                      focusNode: _timeFocusNode,
                      onFieldSubmitted: (val) => {},
                      attribute: "event-time",
                      inputType: InputType.both,
                      format: DateFormat.yMMMd().add_jm(),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Event Date/Time",
                      ),
                      cursorColor: Theme.of(context).primaryColor,
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField(
                      value: _eventType,
                      validator: FormBuilderValidators.required(),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Event Type",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _eventType = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Concert"),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text("Audition"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Jam Session"),
                          value: 2,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if (_eventType == 1)
                Column(
                  children: <Widget>[
                    _buildAuditionChipField(),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              _buildGenreChipField(),
              SizedBox(height: 20),
              Divider(),
              Container(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Card(
                    elevation: 5,
                    child: GoogleMap(
                      onTap: (latlng) =>
                          Navigator.pushNamed(context, MapScreen.routeName),
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentUser.location.latitude,
                            currentUser.location.longitude),
                        zoom: 12.0000,
                      ),
                      markers: {},
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              FlatButton.icon(
                icon: Icon(LineIcons.map),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                label: Text("Set Event Location"),
                textColor: Theme.of(context).primaryColor,
                onPressed: () =>
                    Navigator.pushNamed(context, MapScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildGenreChipField() {
    return FormBuilderChipsInput(
      valueTransformer: (value) {
        for (Genre genre in Utils.genresList) {
          if (value == genre.value) {
            return InputChip(
              key: ObjectKey(genre),
              label: Text(genre.value),
              avatar: genre.genreIcon,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }
        }
        return null;
      },
      inputType: TextInputType.text,
      obscureText: false,
      autocorrect: false,
      keyboardAppearance: Brightness.light,
      textCapitalization: TextCapitalization.none,
      inputAction: TextInputAction.next,
      decoration: InputDecoration(hintText: "Genres"),
      attribute: "genres",
      findSuggestions: (query) => searchGenres(query),
      maxChips: 5,
      validators: [FormBuilderValidators.required()],
      suggestionsBoxMaxHeight: 200,
      chipBuilder: (context, state, profile) {
        return InputChip(
          key: ObjectKey(profile),
          label: Text(profile.genreName),
          onDeleted: () => state.deleteChip(profile),
          avatar: profile.genreIcon,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, profile) {
        return ListTile(
          key: ObjectKey(profile),
          leading: profile.genreIcon,
          title: Text(profile.genreName),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }

  _buildAuditionChipField() {
    return FormBuilderChipsInput(
      valueTransformer: (value) {
        for (Instrument instrument in instruments) {
          if (value == instrument.value) {
            return InputChip(
              key: ObjectKey(instrument),
              label: Text(instrument.value),
              avatar: instrument.instrumentIcon,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }
        }
        return null;
      },
      inputType: TextInputType.text,
      obscureText: false,
      autocorrect: false,
      keyboardAppearance: Brightness.light,
      textCapitalization: TextCapitalization.none,
      inputAction: TextInputAction.next,
      decoration: InputDecoration(hintText: "Instruments to Audition"),
      attribute: "instrument",
      findSuggestions: (query) => searchInstruments(query),
      maxChips: 1,
      //validators: [FormBuilderValidators.required()],
      suggestionsBoxMaxHeight: 200,
      chipBuilder: (context, state, profile) {
        return InputChip(
          key: ObjectKey(profile),
          label: Text(profile.instrumentName),
          onDeleted: () => state.deleteChip(profile),
          avatar: profile.instrumentIcon,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    );
  }
}
