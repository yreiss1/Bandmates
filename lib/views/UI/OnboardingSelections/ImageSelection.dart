import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

class ImageSelection extends StatefulWidget {
  final SwiperController swiperController;
  final Function setImage;

  ImageSelection({this.swiperController, this.setImage});

  @override
  _ImageSelectionState createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  File _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
    widget.setImage(_imageFile);
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
    widget.setImage(_imageFile);
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });

    widget.setImage(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
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
                                  color: Theme.of(context).primaryColor,
                                  width: 0),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.keyboard_arrow_up),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                label: Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                onPressed: () {
                  //FocusScope.of(context).unfocus();

                  widget.swiperController.previous();
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
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
                    widget.swiperController.next();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
