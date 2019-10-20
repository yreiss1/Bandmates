import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:jammerz/AuthService.dart';
import 'dart:io';
import '../../Utils.dart';

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final StorageReference _storage =
      FirebaseStorage.instance.ref().child('profilePhotos');

  StorageUploadTask _storageUploadTask;

  void _startUpload() async {
    final uid = (await Provider.of<AuthService>(context).getUser()).uid;
    String filePath = '${uid}.png';

    setState(() {
      _storageUploadTask = _storage.child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_storageUploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _storageUploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          snapshot?.data?.snapshot?.ref
              .getDownloadURL()
              .then((url) => {Utils.uploadPhotoPath(context, url)});
          double progressPercent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;
          return Column(
            children: <Widget>[
              if (_storageUploadTask.isComplete) Text("Upload Complete!"),
              SizedBox(
                height: 10,
              ),
              if (_storageUploadTask.isPaused)
                FlatButton(
                  child: Icon(LineIcons.play),
                  onPressed: _storageUploadTask.resume,
                ),
              if (_storageUploadTask.isInProgress)
                FlatButton(
                  child: Icon(LineIcons.pause),
                  onPressed: _storageUploadTask.pause,
                ),
              linearProgress(
                context,
                value: progressPercent,
              ),
              Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
            ],
          );
        },
      );
    } else {
      return FlatButton.icon(
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(50)),
        textColor: Theme.of(context).primaryColor,
        color: Colors.white,
        label: Text("Upload Image"),
        icon: Icon(LineIcons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }
}
