import 'package:flutter/material.dart';
import 'package:jammerz/views/HomeScreen.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import '../models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:geocoder/geocoder.dart';
import './OnboardingScreens/ImageCapture.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile-screen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint point;
  final _birthdayFocusNode = FocusNode();
  GlobalKey<FormBuilderState> _fbKey;
  File _imageFile;
  bool _isUploading;
  User currentUser;

  final _bioFocusNode = FocusNode();

  Location location = new Location();
  TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = new TextEditingController();
    _fbKey = GlobalKey<FormBuilderState>();
    _isUploading = false;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _birthdayFocusNode.dispose();
    _bioFocusNode.dispose();

    super.dispose();
  }

  _handleSubmit(BuildContext context) async {
    _fbKey.currentState.save();
    setState(() {
      _isUploading = true;
    });
    String uid = Provider.of<FirebaseUser>(context).uid;
    print("[EditProfileScreen] uid: " + uid);
    String name = _fbKey.currentState.value['name'];
    bool transportation = _fbKey.currentState.value['transportation'];
    bool practice = _fbKey.currentState.value['practice'];
    String bio = _fbKey.currentState.value['bio'];
    String downloadUrl;
    if (_imageFile != null) {
      await _compressImage();
      downloadUrl = await Provider.of<UserProvider>(context)
          .uploadProfileImage(_imageFile, uid);
    }
    downloadUrl = downloadUrl == null ? currentUser.photoUrl : downloadUrl;
    GeoFirePoint location = point == null ? currentUser.location : point;
    User user = User(
        bio: bio ?? currentUser.bio,
        name: name == null ? currentUser.name : name,
        transportation: transportation ?? currentUser.transportation,
        practiceSpace: practice ?? currentUser.practiceSpace,
        photoUrl: downloadUrl,
        uid: uid,
        time: currentUser.time,
        instruments: currentUser.instruments,
        genres: currentUser.genres,
        email: currentUser.email,
        location: location);

    print("[EditProfileScreen] photoUrl: " + user.photoUrl);
    await Provider.of<UserProvider>(context).uploadUser(uid, user);

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context);
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

  fetchImage(File imageFile) {
    setState(() {
      this._imageFile = imageFile;
    });
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
        "[EditProfileScreen] ${first.featureName} : ${first.addressLine} : ${first.subLocality} : ${first.subThoroughfare} : ${first.subAdminArea}");

    _locationController.text = first.subAdminArea;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      currentUser = Provider.of<UserProvider>(context).currentUser;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            LineIcons.arrow_left,
            color: Color(0xFF1d1e2c),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(LineIcons.check),
            color: Color(0xFF1d1e2c),
            onPressed: () => _isUploading ? null : _handleSubmit(context),
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: FormBuilder(
          initialValue: {
            "name": currentUser.name,
            "transportation": currentUser.transportation,
            "practice": currentUser.practiceSpace,
            "bio": currentUser.bio,
            "location": "Somewhere",
          },
          key: _fbKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: <Widget>[
              _isUploading ? linearProgress(context) : Container(),
              ImageCapture(
                  getImageFile: fetchImage, imageUrl: currentUser.photoUrl),
              FormBuilderTextField(
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_birthdayFocusNode);
                },
                attribute: "name",
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: 'What\'s your name?',
                ),
                keyboardType: TextInputType.text,
                validators: [
                  FormBuilderValidators.required(),
                ],
              ),

              /*
          FormBuilderDateTimePicker(
            focusNode: _birthdayFocusNode,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_bioFocusNode);
            },
            attribute: "birthday",
            inputType: InputType.date,
            format: DateFormat("yyyy-MM-dd"),
            decoration: InputDecoration(labelText: "Your Birthday"),
            cursorColor: Theme.of(context).primaryColor,
            enabled: true,
            firstDate: DateTime.now().subtract(Duration(days: 365 * 120)),
            initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
            lastDate: DateTime.now().subtract(Duration(days: 365 * 8)),
            validators: [
              FormBuilderValidators.required(),
            ],
            readOnly: false,
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.done,
          ),
          */
              FormBuilderCheckbox(
                attribute: 'transportation',
                checkColor: Theme.of(context).primaryColor,
                activeColor: Colors.white,
                label: Text("I have a reliable mode of transportation"),
                validators: [],
              ),
              FormBuilderCheckbox(
                attribute: 'practice',
                checkColor: Theme.of(context).primaryColor,
                activeColor: Colors.white,
                label: Text("I have practice space"),
                validators: [],
              ),
              FormBuilderTextField(
                focusNode: _bioFocusNode,
                attribute: "bio",
                decoration: InputDecoration(
                  labelText: "Bio",
                  hintText: 'Tell us about yourself...',
                ),
                keyboardType: TextInputType.text,
                minLines: 1,
                maxLines: 3,
                validators: [FormBuilderValidators.required()],
              ),
              FormBuilderTextField(
                attribute: 'location',
                decoration: InputDecoration(
                  labelText: "Hit the button to find your location",
                ),
                readOnly: true,
                controller: _locationController,
                validators: [FormBuilderValidators.required()],
              ),
              SizedBox(
                height: 20,
              ),
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
                  label: Text("Get My Location"),
                  onPressed: () => _getLocation()),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
