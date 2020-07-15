import 'dart:async';
import 'dart:io';

import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

import '../HomeScreen.dart';

class ClassifiedUploadScreen extends StatefulWidget {
  static const routeName = '/classified-upload-screen';

  @override
  _ClassifiedUploadScreenState createState() => _ClassifiedUploadScreenState();
}

class _ClassifiedUploadScreenState extends State<ClassifiedUploadScreen> {
  GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();
  Completer<GoogleMapController> _mapController = Completer();

  bool _isVisible = true;
  bool _isUploading = false;
  File _imageFile = null;
  int _classifiedType;
  geocoder.Coordinates _coordinates;
  Set<Marker> _markers = Set();

  FocusNode _titleFocusNode = FocusNode();
  FocusNode _textFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

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
    _titleFocusNode.dispose();
    super.dispose();
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
    _markers.add(Marker(
        markerId: MarkerId("Classified Location"), position: setLocation));
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  Icons.add,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                onPressed: () {}),
                          ],
                          expandedHeight: 100,
                          title: Text(
                            "Create and Ad",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildClassifiedUploadCard(),
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
            ],
          ),
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
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: 350,
      width: double.infinity,
    );
  }

  _buildClassifiedUploadCard() {
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
                                Text("Upload an Image for your Ad"),
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
                        hintText: "Classified Title",
                      ),
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FormBuilderTextField(
                      attribute: 'text',
                      focusNode: _textFocusNode,
                      maxLines: null,
                      decoration: new InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Classified Description",
                      ),
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField(
                      value: _classifiedType,
                      validator: FormBuilderValidators.required(),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Classified Type",
                      ),
                      onChanged: (value) {
                        setState(
                          () {
                            _classifiedType = value;
                          },
                        );
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Selling"),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text("Buying"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Looking For"),
                          value: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
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
                label: Text("Set Classified Location"),
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
}
