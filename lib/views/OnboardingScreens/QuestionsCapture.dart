import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geocoder/geocoder.dart' as prefix1;
import 'package:geoflutterfire/geoflutterfire.dart' as prefix0;
import 'package:intl/intl.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:jammerz/views/OnboardingScreens/ImageCapture.dart';
import 'dart:io';
import 'package:line_icons/line_icons.dart';
import 'Uploader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

class QuestionsCapture extends StatefulWidget {
  GlobalKey<FormBuilderState> fbKey;

  QuestionsCapture({@required this.getInfo, @required this.fbKey});
  final Function getInfo;

  @override
  _QuestionsCaptureState createState() => _QuestionsCaptureState();
}

class _QuestionsCaptureState extends State<QuestionsCapture> {
  File _imageFile;
  GeoFirePoint point;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();

  TextEditingController locationController = new TextEditingController();

  final _birthdayFocusNode = FocusNode();

  final _genderFocusNode = FocusNode();

  final _bioFocusNode = FocusNode();

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

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
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
        "${first.featureName} : ${first.addressLine} : ${first.subLocality} : ${first.subThoroughfare} : ${first.subAdminArea}");

    locationController.text = first.subAdminArea;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FormBuilder(
                onChanged: (val) => {
                  widget.fbKey.currentState.save(),
                  widget.getInfo(
                      val['name'],
                      val['birthday'],
                      val['bio'],
                      val['gender'],
                      val['transportation'],
                      val['practice'],
                      point)
                },
                key: widget.fbKey,
                autovalidate: false,
                child: Column(
                  children: <Widget>[
                    ImageCapture(),
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
                    FormBuilderDropdown(
                      attribute: "gender",
                      decoration: InputDecoration(labelText: "Gender"),
                      hint: Text('Select Gender'),
                      validators: [FormBuilderValidators.required()],
                      items: [
                        'Male',
                        'Female',
                        'Transgender Female',
                        'Transgender Male',
                        'Non-Conforming'
                      ]
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text('$gender'),
                              ))
                          .toList(),
                    ),
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
                      firstDate:
                          DateTime.now().subtract(Duration(days: 365 * 120)),
                      initialDate:
                          DateTime.now().subtract(Duration(days: 365 * 18)),
                      lastDate:
                          DateTime.now().subtract(Duration(days: 365 * 8)),
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      readOnly: false,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.done,
                    ),
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
                      controller: locationController,
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
            ],
          ),
        ),
      ),
    );
  }
}
