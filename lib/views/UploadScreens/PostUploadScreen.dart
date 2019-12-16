import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/models/Post.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image/image.dart' as Im;

import 'dart:io';

import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import 'package:path_provider/path_provider.dart';
import '../UI/AspectRatioVideo.dart';
import '../../models/User.dart';

import 'dart:async';

import 'package:video_player/video_player.dart';

class PostUploadScreen extends StatefulWidget {
  static const routeName = '/post-upload';

  @override
  _PostUploadScreenState createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends State<PostUploadScreen> {
  GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();
  TextEditingController locationController = new TextEditingController();
  GeoFirePoint point;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();
  bool _isVideo = false;
  VideoPlayerController _controller;
  String _postID = Uuid().v4();

  final _textFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();

  bool _isUploading = false;

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

    _fbKey.currentState.value['image'] = null;
    _fbKey.currentState.value['video'] = _videoFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _isVideo = false;
      _videoFile = null;
      _imageFile = selected;
    });

    _fbKey.currentState.value['video'] = null;
    _fbKey.currentState.value['image'] = _imageFile;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
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

  _compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_imageFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$_postID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _imageFile = compressedImageFile;
    });
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();
    _fbKey.currentState.value['loc'] = locationController.text;
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isUploading = true;
      });
      if (_imageFile != null) {
        await _compressImage();
      }

      User userObject = Provider.of<UserProvider>(context).currentUser;
      String downloadURL =
          await Provider.of<PostProvider>(context, listen: false)
              .uploadMedia(_imageFile, _postID);

      Post post = new Post(
          text: _fbKey.currentState.value['text'],
          mediaUrl: downloadURL,
          time: DateTime.now(),
          likes: {},
          location: _fbKey.currentState.value['loc']);
      await Provider.of<PostProvider>(context, listen: false)
          .uploadPost(post, _postID, userObject.uid, userObject.name);

      setState(() {
        _isUploading = false;
        _imageFile = null;
        _videoFile = null;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
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
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: uploadHeader("Upload Post", context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            _isUploading ? linearProgress(context) : Container(),
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
              key: _fbKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    focusNode: _textFocusNode,
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).requestFocus(_locationFocusNode);
                    },
                    attribute: 'text',
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
                          focusNode: _locationFocusNode,
                          attribute: 'loc',
                          decoration: InputDecoration(
                            labelText: "Your location",
                          ),
                          readOnly: false,
                          controller: locationController,
                          validators: [],
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
