import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/Post.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:koukicons/pic2.dart';
import 'package:koukicons/speaker.dart';
import 'package:koukicons/film.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';

import 'package:image/image.dart' as Im;

import 'dart:io';

import 'package:location/location.dart';

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
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  AudioPlayer _audioPlayer;
  bool _isAudioPlaying;
  String _postID = Uuid().v4();

  final _textFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();

  bool _isUploading = false;

  File _uploadFile;
  int _fileType;

  bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = true;
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
    if (_controller != null) {
      _controller.dispose();
    }

    if (_audioPlayer != null) {
      _audioPlayer.dispose();
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

  _playAudio() async {
    if (mounted) {
      setState(() {
        _audioPlayer.resume();
        _isAudioPlaying = true;
      });
    }
  }

  _pauseAudio() async {
    setState(() {
      _audioPlayer.pause();
      _isAudioPlaying = false;
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

  _compressVideo() async {
    final _flutterVideoCompress = FlutterVideoCompress();

    final info = await _flutterVideoCompress.compressVideo(_uploadFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true);
    print("[PostUploadScreen] video title: " + info.title);
    setState(() {
      _uploadFile = info.file;
    });
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isUploading = true;
      });
      if (_uploadFile != null && _fileType == 0) {
        await _compressImage();
      }

      if (_uploadFile != null && _fileType == 2) {
        await _compressVideo();
      }

      User userObject = currentUser;
      String downloadURL =
          await Provider.of<PostProvider>(context, listen: false)
              .uploadMedia(_uploadFile, _postID);

      Post post = new Post(
        type: _fileType,
        postId: _postID,
        title: _fbKey.currentState.value['title'],
        text: _fbKey.currentState.value['text'],
        ownerId: currentUser.uid,
        avatar: currentUser.photoUrl,
        username: currentUser.name,
        mediaUrl: downloadURL,
        time: DateTime.now(),
        likes: {},
      );
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
    if (_audioPlayer != null) {
      _audioPlayer.stop();
      _audioPlayer.release();
      _audioPlayer.dispose();
    }

    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    setState(() => _uploadFile = null);
  }

  @override
  Widget build(BuildContext parentContext) {
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
              if (_isVisible)
                Positioned.fill(
                  bottom: 40,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton.extended(
                        icon: Icon(Icons.cloud_upload),
                        label: Text("Upload Work"),
                        onPressed: () => _handleSubmit(),
                        backgroundColor: Theme.of(context).primaryColor,
                      )),
                )
            ],
          ),
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
        return _buildAudioFilePreview();
      } else if (_fileType == 2) {
        //Video
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
                          if (file != null) {
                            setState(() {
                              _fileType = 0;
                              _uploadFile = file;
                            });
                          }
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

                          if (file != null) {
                            setState(() {
                              _fileType = 1;
                              _uploadFile = file;
                            });

                            _audioPlayer = AudioPlayer();
                            await _audioPlayer.setReleaseMode(ReleaseMode
                                .STOP); // set release mode so that it never releases

                            int result = await _audioPlayer.play(file.path,
                                isLocal: true);

                            if (result != 1) {
                              //TODO: Display error
                            }

                            setState(() {
                              _isAudioPlaying = true;
                            });
                          }
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

                          if (file != null) {
                            setState(() {
                              _controller = VideoPlayerController.file(file);
                              _fileType = 2;
                              _uploadFile = file;
                            });

                            _initializeVideoPlayerFuture =
                                _controller.initialize();
                            _controller.setVolume(1.0);
                            _controller.setLooping(true);

                            await _controller.play();
                          }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    FormBuilderTextField(
                      attribute: 'title',
                      textInputAction: TextInputAction.next,
                      focusNode: _titleFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_textFocusNode),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Post Title",
                      ),
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FormBuilderTextField(
                      attribute: 'text',
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      focusNode: _textFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Describe your work",
                      ),
                      validators: [FormBuilderValidators.required()],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFilePreview() {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: _uploadFile != null
                      ? FileImage(_uploadFile)
                      : AssetImage('assets/images/user-placeholder.png')),
            ),
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
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Container(
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(_controller);
                } else {
                  return circularProgress(context);
                }
              },
            ),
          ),
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

  _buildAudioFilePreview() {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/audio-placeholder.png')),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _isAudioPlaying == false
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
                    onPressed: () => _playAudio(),
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
                    onPressed: () => _pauseAudio(),
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
