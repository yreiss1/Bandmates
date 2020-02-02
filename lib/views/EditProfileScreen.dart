import 'dart:async';
import 'dart:io';

import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/models/Influence.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/MapScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:location/location.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../Utils.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState(user: user);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User user;
  _EditProfileScreenState({this.user});
  GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();

  Completer<GoogleMapController> _mapController = Completer();
  Location location = new Location();
  Set<Marker> _markers = Set();
  geocoder.Coordinates _coordinates;
  List<Instrument> _selectedInstruments;
  List<Genre> _selectedGenres;
  List<Influence> _selectedInfluences;
  Map<String, dynamic> _userData;
  Geoflutterfire geo = Geoflutterfire();

  bool _isLoading = false;

  bool _isVisible = false;
  File _imageFile;

  @override
  void initState() {
    super.initState();
    _userData = {
      'name': currentUser.name,
      'bio': currentUser.bio,
      'genres': currentUser.genres ?? [],
      'instruments': currentUser.instruments ?? [],
      'influences': currentUser.influences ?? [],
      'location': currentUser.location,
      'photoUrl': currentUser.photoUrl,
    };
    _selectedInstruments =
        user.instruments.map((inst) => Instrument(name: inst)).toList();
    _selectedGenres = user.genres.map((genre) => Genre(name: genre)).toList();
    _selectedInfluences = user.influences != null
        ? user.influences
            .map((influence) => Influence(name: influence))
            .toList()
        : [];

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

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
    _userData['photoUrl'] = _imageFile;
  }

  void _clear() {
    setState(() => _imageFile = null);
    _userData['photoUrl'] = null;
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
    _userData['photoUrl'] = _imageFile;
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
        Marker(markerId: MarkerId("Your Location"), position: setLocation));

    _userData['location'] = geo.point(
        latitude: setLocation.latitude, longitude: setLocation.longitude);
  }

  Future<List<Instrument>> searchInstruments(String query) async {
    await Future.delayed(Duration(milliseconds: 300), null);
    return Utils.instrumentList
        .map((inst) => inst)
        .where((inst) => inst.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<Genre>> searchGenres(String query) async {
    await Future.delayed(Duration(milliseconds: 300), null);
    return Utils.genresList
        .map((genre) => genre)
        .where(
            (genre) => genre.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  _handleSubmit() async {
    print("[EditProfileScreen] Working");

    setState(() {
      _isLoading = true;
    });
    String downloadUrl;
    if (_imageFile != null) {
      File compressedImage =
          await Utils.compressImage(_imageFile, currentUser.uid);
      downloadUrl = await Provider.of<UserProvider>(context)
          .uploadProfileImage(compressedImage, currentUser.uid);
    }

    _userData['photoUrl'] = downloadUrl;

    User newUser = User(
      bio: _userData['bio'] ?? currentUser.bio,
      name: _userData['name'] ?? currentUser.name,
      uid: currentUser.uid,
      influences: _userData['influences'] ?? currentUser.influences,
      genres: _userData['genres'] ?? currentUser.genres,
      instruments: _userData['instruments'] ?? currentUser.instruments,
      location: _userData['location'] ?? currentUser.location,
      photoUrl: _imageFile == null ? user.photoUrl : downloadUrl,
    );
    currentUser = newUser;

    print("[OnboardingScreen] New User: " + newUser.toJson().toString());

    await Provider.of<UserProvider>(context)
        .uploadUser(currentUser.uid, newUser);

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
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
                                LineIcons.edit,
                                size: 32,
                                color: Colors.white,
                              ),
                              onPressed: () => _handleSubmit(),
                            ),
                          ],
                          expandedHeight: 100,
                          title: Text(
                            "Edit Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SliverFillRemaining(
                          fillOverscroll: false,
                          hasScrollBody: false,
                          child: _buildProfileEditCard(),
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
                      icon: Icon(LineIcons.edit),
                      label: Text("Edit Profile"),
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

  _buildProfileEditCard() {
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
              _imageFile == null
                  ? user.photoUrl == null
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
                      : Badge(
                          elevation: 5,
                          badgeContent: GestureDetector(
                            onTap: () => setState(() {
                              user.photoUrl = null;
                            }),
                            child: Icon(Icons.clear),
                          ),
                          badgeColor: Colors.grey[400],
                          position: BadgePosition.topRight(right: 10, top: 10),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 100,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
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
                              color: Theme.of(context).primaryColor, width: 0),
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: new FileImage(_imageFile)),
                        ),
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
                  children: <Widget>[
                    FormBuilderTextField(
                      attribute: 'name',
                      initialValue: user.name,
                      textInputAction: TextInputAction.next,
                      decoration: new InputDecoration(
                        labelText: "Your Name",
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Your Name",
                      ),
                      onChanged: (value) {
                        _userData['name'] = value;
                      },
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FormBuilderTextField(
                      attribute: 'bio',
                      initialValue: user.bio,
                      maxLines: null,
                      decoration: new InputDecoration(
                        labelText: "Your Bio",
                        focusColor: Theme.of(context).primaryColor,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Event Description",
                      ),
                      onChanged: (value) {
                        _userData['bio'] = value;
                      },
                      validators: [FormBuilderValidators.required()],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    _buildInstrumentInput(),
                    SizedBox(
                      height: 24,
                    ),
                    _buildGenreInput(),
                    SizedBox(
                      height: 24,
                    ),
                    _buildInfluenceInput(),
                  ],
                ),
              ),
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
                      ? Flexible(
                          child: Text(
                            "Tap the map to choose a location",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
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
                            isEvent: false,
                            paramFunction: changeLocation,
                            currentLocation: LatLng(user.location.latitude,
                                user.location.longitude),
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
                        target: LatLng(
                            user.location.latitude, user.location.longitude),
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
            ],
          ),
        ),
      ),
    );
  }

  _buildInstrumentInput() {
    return FlutterTagging<Instrument>(
      emptyBuilder: (context) {
        return ListTile(
          leading: Icon(Icons.not_interested),
          title: Text("No Instrument with that name exists"),
        );
      },
      suggestionsBoxConfiguration:
          SuggestionsBoxConfiguration(hideSuggestionsOnKeyboardHide: false),
      initialItems: _selectedInstruments,
      debounceDuration: Duration(milliseconds: 100),
      textFieldConfiguration: TextFieldConfiguration(
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: const OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(15.0),
            ),
          ),
          hintText: "Search for your Instruments",
        ),
      ),
      findSuggestions: searchInstruments,
      configureChip: (inst) {
        return ChipConfiguration(
          label: Text(inst.name),
          backgroundColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      wrapConfiguration: WrapConfiguration(
        runSpacing: 4,
        spacing: 4,
      ),
      configureSuggestion: (inst) {
        return SuggestionConfiguration(
          title: Text(inst.name),
        );
      },
      onChanged: () {
        _userData['instruments'] =
            _selectedInstruments.map((inst) => inst.name).toList();
      },
    );
  }

  _buildGenreInput() {
    return FlutterTagging<Genre>(
        emptyBuilder: (context) {
          return ListTile(
            leading: Icon(Icons.not_interested),
            title: Text("No Genre with that name exists"),
          );
        },
        initialItems: _selectedGenres,
        hideOnEmpty: true,
        suggestionsBoxConfiguration:
            SuggestionsBoxConfiguration(hideSuggestionsOnKeyboardHide: false),
        textFieldConfiguration: TextFieldConfiguration(
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            focusColor: Theme.of(context).primaryColor,
            border: const OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(15.0),
              ),
            ),
            hintText: "Search for your Genres",
          ),
        ),
        findSuggestions: searchGenres,
        configureChip: (genre) {
          return ChipConfiguration(
            label: Text(genre.name),
            backgroundColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(color: Colors.white),
            deleteIconColor: Colors.white,
          );
        },
        wrapConfiguration: WrapConfiguration(
          runSpacing: 4,
          spacing: 4,
        ),
        configureSuggestion: (genre) {
          return SuggestionConfiguration(
            title: Text(
              genre.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
        onChanged: () {
          _userData['genres'] =
              _selectedGenres.map((genre) => genre.name).toList();
        });
  }

  _buildInfluenceInput() {
    return FlutterTagging<Influence>(
      emptyBuilder: (context) {
        return ListTile(
          leading: Icon(Icons.not_interested),
          title: Text("No Artist with that name exists"),
        );
      },
      suggestionsBoxConfiguration:
          SuggestionsBoxConfiguration(hideSuggestionsOnKeyboardHide: false),
      initialItems: _selectedInfluences,
      hideOnEmpty: false,
      textFieldConfiguration: TextFieldConfiguration(
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: const OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(15.0),
            ),
          ),
          hintText: "Search for your Influences",
        ),
      ),
      findSuggestions: Utils.searchInfluence,
      configureChip: (influence) {
        return ChipConfiguration(
          label: Text(influence.name),
          backgroundColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      wrapConfiguration: WrapConfiguration(
        spacing: 4,
      ),
      configureSuggestion: (influence) {
        return SuggestionConfiguration(
          title: Text(
            influence.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: (influence.country == null && influence.date == null)
              ? Text("")
              : (influence.country == null && influence.date != null)
                  ? Text(influence.date)
                  : (influence.date == null && influence.country != null)
                      ? Text(influence.country)
                      : Text(influence.country + " - " + influence.date),
        );
      },
      onChanged: () {
        _userData['influences'] =
            _selectedInfluences.map((influence) => influence.name).toList();
      },
    );
  }
}
