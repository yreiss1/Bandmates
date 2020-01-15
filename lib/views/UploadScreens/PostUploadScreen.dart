import 'package:bandmates/views/UI/Progress.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/Post.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:koukicons/pic2.dart';
import 'package:koukicons/speaker.dart';
import 'package:koukicons/film.dart';

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
  Future<void> _initializeVideoPlayerFuture;
  String _postID = Uuid().v4();

  final _textFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();

  bool _isUploading = false;

  File _uploadFile;
  int _fileType;

  ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _playVideo() async {
    if (mounted) {
      //await _disposeVideoController();

      setState(() {
        _controller.play();
      });
    }
  }

  _pauseVideo() async {
    setState(() {
      _controller.pause();
    });
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  _compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_uploadFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$_postID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _uploadFile = compressedImageFile;
    });
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();
    _fbKey.currentState.value['loc'] = locationController.text;
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isUploading = true;
      });
      if (_uploadFile != null) {
        await _compressImage();
      }

      User userObject = Provider.of<UserProvider>(context).currentUser;
      String downloadURL =
          await Provider.of<PostProvider>(context, listen: false)
              .uploadMedia(_uploadFile, _postID);

      Post post = new Post(
          postId: _postID,
          text: _fbKey.currentState.value['text'],
          mediaUrl: downloadURL,
          time: DateTime.now(),
          likes: {},
          location: _fbKey.currentState.value['loc']);
      await Provider.of<PostProvider>(context, listen: false).uploadPost(
          post: post,
          postId: _postID,
          uid: userObject.uid,
          name: userObject.name);

      setState(() {
        _isUploading = false;
        _uploadFile = null;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _uploadFile.path,
    );

    setState(() {
      _uploadFile = cropped ?? _uploadFile;
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _uploadFile = null);
  }

  @override
  Widget build(BuildContext parentContext) {
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
                  _buildHeader(),
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        forceElevated: false,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.cloud_upload,
                              size: 32,
                              color: Colors.white,
                            ),
                            onPressed: () => _handleSubmit(),
                          ),
                        ],
                        expandedHeight: 100,
                        title: Text(
                          "Upload Work",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SliverFillRemaining(
                        fillOverscroll: false,
                        hasScrollBody: false,
                        child: _buildPostUploadCard(),
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
                  icon: Icon(Icons.cloud_upload),
                  label: Text("Upload Work"),
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

  Widget _buildFilePreview() {
    if (_uploadFile != null) {
      if (_fileType == 0) {
        //Image
        return _buildImageFilePreview();
      } else if (_fileType == 1) {
        //Audio

      } else if (_fileType == 2) {
        return _buildVideoFilePreview();
      }
    }
  }

  Widget _buildFileSelection() {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Choose file type to upload",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FittedBox(
                      child: FloatingActionButton(
                        heroTag: 'image',
                        backgroundColor: Colors.white,
                        elevation: 10,
                        child: KoukiconsPic2(
                          height: 30,
                          width: 30,
                        ),
                        onPressed: () async {
                          File file =
                              await FilePicker.getFile(type: FileType.IMAGE);

                          setState(() {
                            _fileType = 0;
                            _uploadFile = file;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FittedBox(
                      child: FloatingActionButton(
                        heroTag: 'audio',
                        backgroundColor: Colors.white,
                        elevation: 10,
                        child: KoukiconsSpeaker(
                          height: 100,
                          width: 100,
                        ),
                        onPressed: () async {
                          File file =
                              await FilePicker.getFile(type: FileType.AUDIO);

                          setState(() {
                            _fileType = 1;
                            _uploadFile = file;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Audio",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FittedBox(
                      child: FloatingActionButton(
                        heroTag: 'video',
                        backgroundColor: Colors.white,
                        elevation: 10,
                        child: KoukiconsFilm(),
                        onPressed: () async {
                          File file =
                              await FilePicker.getFile(type: FileType.VIDEO);
                          print(file.path);
                          setState(() {
                            _controller = VideoPlayerController.file(file);
                            _fileType = 2;
                            _uploadFile = file;
                            _chewieController = ChewieController(
                              videoPlayerController: _controller,
                              aspectRatio: 3 / 2,
                              autoPlay: true,
                              looping: true,
                            );
                          });

                          // _initializeVideoPlayerFuture =
                          //     _controller.initialize();
                          // _controller.setVolume(1.0);
                          // _controller.setLooping(true);

                          // await _controller.play();
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Video",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildHeader() {
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

  _buildPostUploadCard() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 300,
                  child: _uploadFile == null
                      ? _buildFileSelection()
                      : _buildFilePreview(),
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
                          hintText: "Work Title",
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        focusNode: _textFocusNode,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                        decoration: new InputDecoration(
                          focusColor: Theme.of(context).primaryColor,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          hintText: "Describe your work",
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildImageFilePreview() {
    return Column(
      children: <Widget>[
        Container(
          width: 200,
          height: 180,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: new DecorationImage(
                fit: BoxFit.cover,
                image: _uploadFile != null
                    ? FileImage(_uploadFile)
                    : AssetImage('assets/images/user-placeholder.png')),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton.icon(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
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
        ),
      ],
    );
  }

  Widget _buildVideoFilePreview() {
    return Column(
      children: <Widget>[
        // Container(
        //   height: 180,
        //   width: 200,
        //   child: FutureBuilder(
        //     future: _initializeVideoPlayerFuture,
        //     builder: (BuildContext context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.done) {
        //         return AspectRatioVideo(_controller);
        //       } else {
        //         return circularProgress(context);
        //       }
        //     },
        //   ),
        // ),

        Chewie(
          controller: _chewieController,
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _controller.value.isPlaying == false
                ? FlatButton.icon(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(50)),
                    color: Theme.of(context).primaryColor,
                    icon: Icon(LineIcons.play),
                    textColor: Colors.white,
                    label: Text("Play"),
                    onPressed: () => _playVideo(),
                  )
                : FlatButton.icon(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(50)),
                    color: Theme.of(context).primaryColor,
                    icon: Icon(LineIcons.pause),
                    textColor: Colors.white,
                    label: Text("Pause"),
                    onPressed: () => _pauseVideo(),
                  ),
            FlatButton.icon(
              icon: Icon(LineIcons.refresh),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              label: Text("Clear"),
              textColor: Theme.of(context).primaryColor,
              onPressed: () => _clear(),
            ),
          ],
        ),
      ],
    );
  }
}
