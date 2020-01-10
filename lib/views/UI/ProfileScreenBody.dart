import 'dart:async';

import 'package:bandmates/Utils.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/UI/PostItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/User.dart';
import 'package:line_icons/line_icons.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/Post.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

class ProfileScreenBody extends StatefulWidget {
  final User user;
  ProfileScreenBody({@required this.user});

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with SingleTickerProviderStateMixin {
  User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = prefix0.currentUser;
    _getUserPosts();
  }

  _getUserPosts() async {
    setState(() {
      _isLoading = true;
    });

    //TODO: Get work
    QuerySnapshot querySnap = await Firestore.instance
        .collection("posts")
        .document(widget.user.uid)
        .collection("userPosts")
        .orderBy("time", descending: true)
        .getDocuments();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  _uploadWork(BuildContext context) async {
    File chosen = await FilePicker.getFile(type: FileType.ANY);
    if (chosen != null) {
      Alert(
          context: context,
          type: AlertType.none,
          title: "Upload Work",
          content: Column(
            children: <Widget>[Image.file(chosen), TextField()],
          ),
          buttons: [
            DialogButton(
              child: Text("Upload"),
              onPressed: () {},
            ),
            DialogButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
    }

    print("[ProfileScreenBody] mimetype: " + lookupMimeType(chosen.path));
  }

  @override
  Widget build(BuildContext context) {
    print("[ProfileScreenBody] uid: " + widget.user.uid.toString());

    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildHeader(),
              Column(
                children: <Widget>[
                  Container(
                    height: 1000,
                  )
                ],
              )
            ],
          ),
          Positioned(
            child: Column(
              children: <Widget>[
                buildProfileCard(),
                SizedBox(
                  height: 4,
                ),
                buildInfoCard()
              ],
            ),
            top: MediaQuery.of(context).size.height * 0.18,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: widget.user.photoUrl != null
                  ? CircularProfileAvatar(
                      widget.user.photoUrl,
                      radius: 60,
                      borderColor: Colors.white,
                      borderWidth: 6,
                    )
                  : CircularProfileAvatar(
                      "https://www.bsn.eu/wp-content/uploads/2016/12/user-icon-image-placeholder-300-grey.jpg",
                      radius: 60,
                      borderColor: Colors.white,
                      borderWidth: 3,
                    ),
            ),
            top: MediaQuery.of(context).size.height * 0.1,
          ),
        ],
      ),
    );
  }

  buildHeader() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 32),
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          widget.user.uid != _currentUser.uid
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        LineIcons.arrow_left,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        LineIcons.ellipsis_h,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () => print("Menu clicked"),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      LineIcons.ellipsis_h,
                      size: 32,
                      color: Colors.white,
                    ),
                    onPressed: () => print("Menu clicked"),
                  ),
                )
        ],
      ),
    );
  }

  buildProfileCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Text(
                widget.user.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(
                height: 4,
              ),
              Text(widget.user.bio),
              widget.user.uid == _currentUser.uid
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
                          icon: Icon(LineIcons.calendar),
                          textColor: Colors.white,
                          label: Text(
                            "Create Event",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {},
                        ),
                        FlatButton.icon(
                          icon: Icon(LineIcons.music),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          label: Text(
                            "Upload Work",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {},
                        ),
                      ],
                    )
                  : FlatButton.icon(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.white,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(50)),
                      color: Color(0xff829abe),
                      icon: Icon(LineIcons.comment),
                      textColor: Colors.white,
                      label: Text(
                        "Chat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {},
                    ),
            ],
          ),
        ),
      ),
    );
  }

  buildInfoCard() {
    final coordinates = new geocoder.Coordinates(
        prefix0.currentUser.location.latitude,
        prefix0.currentUser.location.longitude);

    return FutureBuilder<List<geocoder.Address>>(
      future:
          geocoder.Geocoder.google("AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI")
              .findAddressesFromCoordinates(coordinates),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }

        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(25),
              child: Wrap(children: [
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.place,
                      color: Theme.of(context).primaryColor,
                    ),
                    Flexible(
                      child: Text(
                        snapshot.data.first.locality +
                            ", " +
                            snapshot.data.first.adminArea,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Container(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Card(
                      elevation: 5,
                      child:
                          /* GoogleMap(
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.user.location.latitude,
                              widget.user.location.longitude),
                          zoom: 12.0000,
                        ),
                        circles: {
                          Circle(
                              strokeWidth: 1,
                              radius: 1500,
                              fillColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.4),
                              circleId: CircleId("User Location"),
                              center: LatLng(widget.user.location.latitude,
                                  widget.user.location.longitude))
                        },
                      ), */
                          Container(),
                    ),
                  ),
                ),
                Divider(),
                Text(
                  "Instruments",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    runSpacing: 0,
                    spacing: 4,
                    children: [
                      for (String inst in widget.user.instruments.keys)
                        Chip(
                          label: Text(inst),
                        )
                    ],
                  ),
                ),
                Divider(),
                Text(
                  "Genres",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    runSpacing: 0,
                    spacing: 4,
                    children: [
                      for (String genre in widget.user.genres.keys)
                        Chip(
                          label: Text(genre),
                        )
                    ],
                  ),
                ),
                Divider(),
                Text(
                  widget.user.name + "'s Work",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                          ? 2
                          : 3),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return GridTile(
                      footer: Text("Hello World!"),
                      child: Image.network(
                          "https://picsum.photos/id/$index/200/300"),
                    );
                  },
                )
              ]),
            ),
          ),
        );
      },
    );
  }
}
