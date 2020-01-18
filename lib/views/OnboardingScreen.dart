import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'HomeScreen.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

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

  File _imageFile;

  SwiperController _swiperController;

  @override
  void initState() {
    super.initState();

    _swiperController = SwiperController();

    _userData = {
      'name': "",
      'bio': "",
      'birthday': null,
      'transportation': false,
      'practice': false,
      'genres': [],
      'instruments': [],
      'location': null,
    };
  }

  getGenresData(List<dynamic> genres) {
    print('[OnboardingScreen] genres: ' + genres.toString());
    setState(() {
      _userData['genres'] =
          Map.fromIterable(genres, key: (k) => k, value: (v) => true);
    });
  }

  getInstrumentsData(List<dynamic> instruments) {
    print("[OnboardingScreen] instruments: " + instruments.toString());

    setState(() {
      _userData['instruments'] =
          Map.fromIterable(instruments, key: (k) => k, value: (v) => true);
    });
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
      child: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            _buildHeader(),
            _buildSwiperArea(),
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
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Swiper(
              //physics: NeverScrollableScrollPhysics(),
              curve: Curves.easeInOut,
              loop: false,
              scrollDirection: Axis.vertical,
              itemCount: 5,
              viewportFraction: 0.6,
              scale: 0.55,

              // pagination: SwiperPagination(
              //   alignment: Alignment.centerLeft,
              // ),
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
                  default:
                    return Container();
                }
              },
            ),
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          //physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 32,
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

                    return null;
                  },
                ),
              ]),
            ),
            SizedBox(
              height: 24,
            ),
            FlatButton.icon(
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
                    _swiperController.next();
                  }
                }),
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
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
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
                        width: 180,
                        height: 180,
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
                      width: 180,
                      height: 180,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 0),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
            SizedBox(
              height: 16,
            ),
            FlatButton.icon(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.keyboard_arrow_down),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              label: Text(
                "Next",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              textColor: Colors.white,
              onPressed: () => _swiperController.next(),
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
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            "Your Location",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          TextField(
            textInputAction: TextInputAction.next,

            decoration: new InputDecoration(
              focusColor: Theme.of(context).primaryColor,
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(15.0),
                ),
              ),
              hintText: "Event Title",
            ),
            //validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  Widget _buildThree() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Column(
        children: <Widget>[
          Text("Your Genre"),
          SizedBox(
            height: 8,
          ),
          TextField(
            textInputAction: TextInputAction.next,

            decoration: new InputDecoration(
              focusColor: Theme.of(context).primaryColor,
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(15.0),
                ),
              ),
              hintText: "Event Title",
            ),
            //validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  Widget _buildFour() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Column(
        children: <Widget>[
          Text("Your Instruments"),
          SizedBox(
            height: 8,
          ),
          TextField(
            textInputAction: TextInputAction.next,

            decoration: new InputDecoration(
              focusColor: Theme.of(context).primaryColor,
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(15.0),
                ),
              ),
              hintText: "Event Title",
            ),
            //validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }
}
