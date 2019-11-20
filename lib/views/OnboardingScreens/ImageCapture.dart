import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import './Uploader.dart';
import 'dart:io';
import 'package:line_icons/line_icons.dart';

import 'package:image_picker/image_picker.dart';

class ImageCapture extends StatefulWidget {
  static const routeName = '/image-capture';
  final Function getImageFile;
  final String imageUrl;
  ImageCapture({this.getImageFile, this.imageUrl});

  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  File _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
    widget.getImageFile(_imageFile);
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
    widget.getImageFile(_imageFile);
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
    widget.getImageFile(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _imageFile == null
              ? Container(
                  width: 180,
                  height: 180,
                  decoration: new BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2),
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.imageUrl != null
                            ? NetworkImage(widget.imageUrl)
                            : AssetImage('assets/images/user-placeholder.png')),
                  ),
                )
              : Container(
                  width: 180,
                  height: 180,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 0),
                    image: new DecorationImage(
                        fit: BoxFit.cover, image: new FileImage(_imageFile)),
                  ),
                ),
          SizedBox(
            height: 20,
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
        ],
      ),
    );
  }
}
