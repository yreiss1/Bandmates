import 'dart:io';

import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:device_calendar/device_calendar.dart' as calendar;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

import 'package:bandmates/models/Event.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import '../../Utils.dart';
import '../../models/Event.dart';
import 'package:uuid/uuid.dart';
import '../../models/Instrument.dart';
import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';

import 'dart:async';

class EventUploadScreen extends StatefulWidget {
  static const routeName = '/event-upload';

  @override
  _EventUploadScreenState createState() => _EventUploadScreenState();
}

class _EventUploadScreenState extends State<EventUploadScreen> {
  GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();
  Completer<GoogleMapController> _mapController = Completer();
  Location location = new Location();
  Set<Marker> _markers = Set();
  geocoder.Coordinates _coordinates;
  Geoflutterfire geo = Geoflutterfire();
  bool _isAudition = false;
  bool _isUploading = false;
  DateTime _startTime;
  DateTime _endTime;
  File _imageFile;
  int index = 0;
  String _eventID = Uuid().v4();

  TextEditingController _textEditingController;
  calendar.DeviceCalendarPlugin _deviceCalendarPlugin;
  List<calendar.Calendar> _calendars;

  FocusNode _titleFocusNode = FocusNode();
  FocusNode _textFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();

  int _eventType;

  bool _isVisible;

  CameraPosition _initialCamera;
  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _textEditingController = TextEditingController();
    _deviceCalendarPlugin = calendar.DeviceCalendarPlugin();
    _calendars = List<calendar.Calendar>();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {
          setState(() {
            _isVisible = false;
          });
        } else {
          setState(() {
            _isVisible = true;
          });
        }
      },
    );
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

  changeLocation(LatLng setLocation) async {
    setState(() {
      _coordinates =
          new geocoder.Coordinates(setLocation.latitude, setLocation.longitude);
    });

    final GoogleMapController controller = await _mapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: setLocation, zoom: 12)));

    controller.animateCamera(CameraUpdate.newLatLngZoom(setLocation, 14));
    _markers.clear();
    _markers.add(
        Marker(markerId: MarkerId("Event Location"), position: setLocation));
  }

  _openDateTimePicker() {
    DateTimeRangePicker(
        initialStartTime: _startTime == null ? DateTime.now() : _startTime,
        mode: DateTimeRangePickerMode.dateAndTime,
        initialEndTime: _endTime == null
            ? DateTime.now().add(Duration(hours: 2))
            : _endTime,
        onConfirm: (start, end) {
          if (start.isAfter(end)) {
            Utils.buildErrorDialog(
                context, "Event end time must come after start time!");
            return;
          }
          _startTime = start;
          _endTime = end;
          _textEditingController.text = Utils.formateDateTime(start, end);

          print(start);
          print(end);
        }).showPicker(context);
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isUploading = true;
    });
    if (_coordinates == null) {
      //TODO: Show message that says that location must not be null!!
      Utils.buildErrorDialog(
          context, "You must set a location for this event!");
      setState(() {
        _isUploading = false;
      });
      return;
    }

    if (_endTime == null || _startTime == null) {
      Utils.buildErrorDialog(
          context, "You must set a start and end time to your event!");
      setState(() {
        _isUploading = false;
      });
      return;
    }

    if (_fbKey.currentState.saveAndValidate() && _eventType != null) {
      var permissionGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionGranted.isSuccess && !permissionGranted.data) {
        permissionGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionGranted.isSuccess || !permissionGranted.data) {
          setState(() {
            _isUploading = false;
          });
          return;
        }
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      _calendars = calendarsResult?.data;

      if (_imageFile != null) {}

      List<dynamic> audition = _isAudition == false
          ? null
          : _fbKey.currentState.value['audition'].toList();
      String downloadUrl;
      if (_imageFile != null) {
        StorageUploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child("events")
            .child("event_$_eventID.jpg")
            .putFile(_imageFile);
        StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
        downloadUrl = await storageSnap.ref.getDownloadURL();
      }

      Event event = new Event(
        name: currentUser.name,
        ownerId: currentUser.uid,
        eventId: _eventID,
        photoUrl: downloadUrl,
        title: _fbKey.currentState.value['title'],
        text: _fbKey.currentState.value['text'],
        location: GeoFirePoint(_coordinates.latitude, _coordinates.longitude),
        type: _eventType,
        start: _startTime,
        end: _endTime,
        audition: audition,
      );
      await Provider.of<EventProvider>(context).uploadEvent(event);

      calendar.Event calEvent =
          calendar.Event(_calendars[0].id, start: _startTime, end: _endTime);
      await _deviceCalendarPlugin.createOrUpdateEvent(calEvent);

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
        child: ModalProgressHUD(
          inAsyncCall: _isUploading,
          progressIndicator: circularProgress(context),
          opacity: .5,
          dismissible: false,
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
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildEventUploadCard(),
                          ]),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.all(60),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              if (_isVisible)
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
      ),
    );
  }

  buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
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
            mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FormBuilderTextField(
                      attribute: 'title',
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
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FormBuilderTextField(
                      attribute: 'text',
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
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _textEditingController,
                      onTap: () => _openDateTimePicker(),
                      decoration: new InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        hintText: "Choose a Date and Time",
                      ),
                    ),
                    FlatButton.icon(
                      label: Text("Choose a time and date"),
                      icon: Icon(LineIcons.calendar),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.white,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(50)),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: () => _openDateTimePicker(),
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
                        setState(
                          () {
                            _eventType = value;
                          },
                        );
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
                        ),
                        DropdownMenuItem(
                          child: Text("Open Mic"),
                          value: 3,
                        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    LineIcons.map_marker,
                    color: Theme.of(context).primaryColor,
                  ),
                  _coordinates == null
                      ? Text("Tap the map to choose a location",
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : FutureBuilder<List<geocoder.Address>>(
                          future: geocoder.Geocoder.google(
                                  "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI")
                              .findAddressesFromCoordinates(_coordinates),
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
                            );
                          },
                        ),
                ],
              ),
              Container(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Card(
                    elevation: 5,
                    child: GoogleMap(
                      onTap: (latlng) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            isEvent: true,
                            paramFunction: changeLocation,
                            currentLocation: LatLng(
                                currentUser.location.latitude,
                                currentUser.location.longitude),
                          ),
                        ),
                      ),
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentUser.location.latitude,
                            currentUser.location.longitude),
                        zoom: 12.0000,
                      ),
                      markers: _markers,
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
