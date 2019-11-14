import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:jammerz/views/UploadScreens/PostUploadScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'UploadScreens/EventUploadScreen.dart';
import 'dart:async';

import 'package:search_map_place/search_map_place.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  GlobalKey<FormBuilderState> fbKey;

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File _imageFile;
  Set<Marker> markers = Set();
  Completer<GoogleMapController> _mapController = Completer();

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    File selected = await ImagePicker.pickImage(
        source: source, maxHeight: 675, maxWidth: 960);

    setState(() {
      _imageFile = selected;
    });
  }

  final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(-20.3000, -40.2990),
    zoom: 14.0000,
  );

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

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  color: Theme.of(parentContext).primaryColor,
                  icon: Icon(LineIcons.camera),
                  textColor: Colors.white,
                  label: Text("From Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: FlatButton.icon(
                  icon: Icon(LineIcons.image),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(parentContext).primaryColor,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text("From Gallery"),
                  textColor: Theme.of(parentContext).primaryColor,
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: FlatButton.icon(
                  icon: Icon(LineIcons.file_text),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(parentContext).primaryColor,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text("No Image"),
                  textColor: Theme.of(parentContext).primaryColor,
                  onPressed: () => {},
                ),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen(context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Create an audition/gig/lesson"),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              "Create an Event",
              style: TextStyle(color: Colors.white),
            ),
            color: Theme.of(context).primaryColor,
            onPressed: () => selectImage(context),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              "Upload a Post",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            color: Colors.white,
            onPressed: () => selectImage(context),
          ),
        ],
      ),
    );
  }

  Scaffold buildPostForm() {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(_imageFile))),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          FormBuilder(
            autovalidate: false,
            key: widget.fbKey,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  attribute: "title",
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: 'What\'s the event title?',
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                FormBuilderTextField(
                  attribute: "description",
                  decoration: InputDecoration(
                    labelText: "Description",
                    hintText: 'Add a description to your event!',
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, PostUploadScreen.routeName),
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Upload a Post",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: new ColorFilter.mode(
                                  Colors.black.withOpacity(.6),
                                  BlendMode.hardLight),
                              image:
                                  AssetImage('assets/images/silhouette.jpg'))),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, EventUploadScreen.routeName),
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Create an Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.hardLight),
                          image: AssetImage('assets/images/concert.jpg'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 120,
                margin: EdgeInsets.only(bottom: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Discover Musicans",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(
                                Colors.black.withOpacity(0.6),
                                BlendMode.hardLight),
                            image: AssetImage('assets/images/musicians.jpg'))),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
