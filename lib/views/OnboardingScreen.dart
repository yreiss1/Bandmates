import 'package:bandmates/AuthService.dart';
import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/models/Influence.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/MapScreen.dart';

import 'package:bandmates/views/UI/OnboardingSelections/GenreSelection.dart';
import 'package:bandmates/views/UI/OnboardingSelections/InfluenceSelection.dart';
import 'package:bandmates/views/UI/OnboardingSelections/InstrumentSelection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../Utils.dart';
import 'HomeScreen.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

final GlobalKey<FormBuilderState> personalKey =
    GlobalKey<FormBuilderState>(debugLabel: "PersonalCapture");

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Map<String, dynamic> _userData;

  GlobalKey<FormBuilderState> genreKey =
      GlobalKey<FormBuilderState>(debugLabel: "GenreCapture");
  GlobalKey<FormBuilderState> instrumentKey =
      GlobalKey<FormBuilderState>(debugLabel: "InstrumentCapture");

  final _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "OnboardingScreenScaffold");

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _mapController = Completer();
  geocoder.Coordinates _coordinates;
  LocationData _currentLocation;
  Set<Circle> _circles = Set<Circle>();

  File _imageFile;

  SwiperController _swiperController = SwiperController();

  GoogleMap _googleMap;
  Swiper _swiper;

  List<Instrument> _initialValues = [Instrument(name: "guitar")];
  Xml2Json xml2json;

  InfluenceSelection _influenceSelection;
  GenreSelection _genreSelection;
  InstrumentSelection _instrumentSelection;

  bool _lastCard = false;

  @override
  void initState() {
    super.initState();
    xml2json = new Xml2Json();
    _getCurrentLocation();
    _lastCard = false;
    _userData = {
      'name': "",
      'bio': "",
      'transportation': false,
      'practice': false,
      'genres': [],
      'instruments': [],
      'influences': [],
      'location': null,
      'photoUrl': null,
    };
    _influenceSelection = InfluenceSelection(
      swiperController: _swiperController,
      userData: _userData,
    );

    _genreSelection = GenreSelection(
      swiperController: _swiperController,
      userData: _userData,
    );

    _instrumentSelection = InstrumentSelection(
      swiperController: _swiperController,
      userData: _userData,
    );
    _swiper = Swiper(
      physics: NeverScrollableScrollPhysics(),
      curve: Curves.easeInOut,
      loop: false,
      scrollDirection: Axis.vertical,
      itemCount: 6,
      viewportFraction: 0.7,
      scale: 0,
      onIndexChanged: (index) => index == 5
          ? setState(() {
              _lastCard = true;
            })
          : setState(() {
              _lastCard = false;
            }),
      controller: _swiperController,
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return _buildZero();
            break;
          case 1:
            return _buildOne();
            break;
          case 2:
            return _buildTwo();
            break;
          case 3:
            return _buildThree();
            break;
          case 4:
            return _buildFour();
            break;
          case 5:
            return _buildFive();
            break;
          default:
            return Container();
        }
      },
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _initialValues.clear();

    super.dispose();
  }

  _getCurrentLocation() async {
    var location = new Location();

    try {
      _currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      Utils.buildErrorDialog(context, e.message);
    }
  }

  changeLocation(LatLng setLocation) async {
    setState(() {
      _coordinates =
          new geocoder.Coordinates(setLocation.latitude, setLocation.longitude);
    });

    final GoogleMapController controller = await _mapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: setLocation, zoom: 13)));

    controller.animateCamera(CameraUpdate.newLatLngZoom(setLocation, 14));

    _circles.clear();
    _circles.add(
      Circle(
        strokeWidth: 1,
        radius: 1000,
        fillColor: Color(0xff53172c).withOpacity(0.4),
        circleId: CircleId("Your Location"),
        center: LatLng(setLocation.latitude, setLocation.longitude),
      ),
    );
  }

  _createUser() async {
    var uid = Provider.of<FirebaseUser>(context).uid;

    if (_imageFile != null) {
      _compressImage();
      await Provider.of<UserProvider>(context)
          .uploadProfileImage(_imageFile, uid);
    }
    await Provider.of<UserProvider>(context).uploadUser(
      uid,
      User(
        bio: _userData['bio'],
        name: _userData['name'],
        uid: uid,
        influences: _userData['influences'],
        genres: _userData['genres'],
        instruments: _userData['instruments'],
        practiceSpace: _userData['practice'],
        transportation: _userData['transportation'],
        location: _userData['location'],
        photoUrl: _userData['photoUrl'],
      ),
    );

    Navigator.pop(context);
  }

  getUserData(
      String name,
      DateTime birthday,
      String bio,
      String gender,
      bool hasTransportation,
      bool hasPracticeSpace,
      GeoFirePoint point,
      File imageFile) {
    setState(() {
      _userData['name'] = name;
      _userData['bio'] = bio;
      _userData['transportation'] =
          hasTransportation == null ? false : hasTransportation;
      _userData['practice'] =
          hasPracticeSpace == null ? false : hasPracticeSpace;
      _userData['timestamp'] = null;
      _userData['location'] = point;

      _imageFile = imageFile;
    });
  }

  _compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final uid = currentUser.uid;
    Im.Image imageFile = Im.decodeImage(_imageFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$uid.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _imageFile = compressedImageFile;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }

  /// Remove image
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            _buildHeader(),
            _buildSwiperArea(),
            if (_lastCard)
              Positioned.fill(
                bottom: 16,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton.extended(
                    heroTag: 'onboarding',
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text(
                      "Create User",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: Icon(Icons.person),
                    onPressed: () => print("Create User"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 44),
      height: 250,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Welcome to Bandmates",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            "Now to get to know you alittle better",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  _buildSwiperArea() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 8),
              child: _swiper),
        ),
      ],
    );
  }

  Widget _buildZero() {
    FocusNode _descFocus = new FocusNode();

    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Who are you?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocus),
                        textInputAction: TextInputAction.next,
                        decoration: new InputDecoration(
                          focusColor: Theme.of(context).primaryColor,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          hintText: "Enter your Name",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Name cannot be empty';
                          }

                          if (value.length <= 3) {
                            return 'Name must be longer than 3 characters';
                          }

                          setState(() {
                            _userData['name'] = value;
                          });

                          return null;
                        },
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        focusNode: _descFocus,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        decoration: new InputDecoration(
                          focusColor: Theme.of(context).primaryColor,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          hintText: "Who are you? What are you looking for?",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Your bio cannot be empty';
                          }

                          if (value.length <= 6) {
                            return 'Bio must be longer than 6 characters';
                          }

                          setState(() {
                            _userData['bio'] = value;
                          });

                          return null;
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.keyboard_arrow_down),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      FocusScope.of(context).unfocus();
                      _swiperController.next();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOne() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Text(
                    "Your Image",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  _imageFile == null
                      ? GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Material(
                            elevation: 10,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(),
                            child: Container(
                              width: 200,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.image,
                                    size: 32,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text("Upload a Profile Image"),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Material(
                          elevation: 10,
                          clipBehavior: Clip.antiAlias,
                          shape: CircleBorder(),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0),
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: new FileImage(_imageFile)),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 16,
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
                              label: Text("Crop",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              label: Text("Redo",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              label: Text("Camera",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              label: Text("Gallery",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.keyboard_arrow_up),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                label: Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                onPressed: () {
                  //FocusScope.of(context).unfocus();

                  _swiperController.previous();
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.keyboard_arrow_down),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  onPressed: () {
                    _swiperController.next();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwo() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Text(
                    "Your Location",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        LineIcons.map_marker,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      _coordinates == null
                          ? Text("Tap the map to choose a location",
                              style: TextStyle(fontWeight: FontWeight.bold))
                          : Flexible(
                              child: FutureBuilder<List<geocoder.Address>>(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                  Container(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Card(
                        elevation: 5,
                        // child: Container(), GoogleMap(
                        //   onTap: (latlng) => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => MapScreen(
                        //         isEvent: false,
                        //         paramFunction: changeLocation,
                        //         currentLocation: _coordinates == null
                        //             ? LatLng(_currentLocation.latitude,
                        //                 _currentLocation.longitude)
                        //             : LatLng(_coordinates.latitude,
                        //                 _coordinates.longitude),
                        //       ),
                        //     ),
                        //   ),
                        //   scrollGesturesEnabled: false,
                        //   zoomGesturesEnabled: false,
                        //   myLocationButtonEnabled: false,
                        //   mapType: MapType.normal,
                        //   onMapCreated: (GoogleMapController controller) {
                        //     if (_mapController.isCompleted == false) {
                        //       _mapController.complete(controller);
                        //     }
                        //   },
                        //   initialCameraPosition: CameraPosition(
                        //     target: _coordinates == null
                        //         ? LatLng(_currentLocation.latitude,
                        //             _currentLocation.longitude)
                        //         : LatLng(
                        //             _coordinates.latitude, _coordinates.longitude),
                        //     zoom: 13.0000,
                        //   ),
                        //   circles: _coordinates != null
                        //       ? {
                        //           Circle(
                        //             strokeWidth: 1,
                        //             radius: 1000,
                        //             fillColor: Color(0xff53172c).withOpacity(0.4),
                        //             circleId: CircleId("Set Location"),
                        //             center: LatLng(_coordinates.latitude,
                        //                 _coordinates.longitude),
                        //           ),
                        //         }
                        //       : null,
                        // ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.keyboard_arrow_up),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                label: Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                onPressed: () {
                  //FocusScope.of(context).unfocus();

                  _swiperController.previous();
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.keyboard_arrow_down),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  onPressed: () {
                    _userData['location'] = GeoFirePoint(
                        _currentLocation.longitude, _currentLocation.longitude);
                    _swiperController.next();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThree() {
    return _instrumentSelection;
  }

  Widget _buildFour() {
    return _genreSelection;
  }

  Widget _buildFive() {
    return _influenceSelection;
  }
}
