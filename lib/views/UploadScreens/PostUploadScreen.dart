import 'package:flutter/material.dart';
import 'package:jammerz/views/UI/Header.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'dart:io';

import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import '../UI/AspectRatioVideo.dart';

import 'dart:async';

import 'package:video_player/video_player.dart';

class PostUploadScreen extends StatefulWidget {
  static const routeName = '/post-upload';

  @override
  _PostUploadScreenState createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends State<PostUploadScreen> {
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  TextEditingController locationController = new TextEditingController();
  GeoFirePoint point;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();
  String _retrieveDataError;
  dynamic _pickImageError;
  bool _isVideo = false;
  VideoPlayerController _controller;

  File _imageFile;
  File _videoFile;
  String filename;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo(ImageSource source) async {
    File selected = await ImagePicker.pickVideo(source: source);
    await _playVideo(selected);
    setState(() {
      _isVideo = true;
      _imageFile = null;
      _videoFile = selected;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _isVideo = false;
      _imageFile = selected;
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
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

    locationController.text = first.addressLine;
  }

  Future<void> _playVideo(File file) async {
    if (file != null && mounted) {
      //await _disposeVideoController();
      _controller = VideoPlayerController.file(file);
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
    }
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: uploadHeader("Upload Post", context, fbKey),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              height: 220,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: _imageFile == null && _isVideo == false
                    ? Text("No Image Selected")
                    : _isVideo
                        ? _controller.value.initialized
                            ? AspectRatio(
                                aspectRatio: 16 / 9,
                                //aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              )
                            : Text("Error")
                        : AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: _imageFile == null
                                          ? AssetImage(
                                              'assets/images/user-placeholder.png')
                                          : FileImage(_imageFile))),
                            ),
                          ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
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
                  label: Text("Photo"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  color: Theme.of(context).primaryColor,
                  icon: Icon(LineIcons.video_camera),
                  textColor: Colors.white,
                  label: Text("Video"),
                  onPressed: () => _pickVideo(ImageSource.camera),
                ),
              ],
            ),
            Divider(
              thickness: 1,
            ),
            SizedBox(
              height: 10,
            ),
            FormBuilder(
              autovalidate: false,
              key: fbKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "description",
                    decoration: InputDecoration(
                      labelText: "What's on your mind?",
                      hintText: 'Let us know what\'s up',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
