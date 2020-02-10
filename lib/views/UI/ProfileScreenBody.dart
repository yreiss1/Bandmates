import 'dart:typed_data';

import 'package:bandmates/AuthService.dart';
import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/Chat.dart';
import 'package:bandmates/models/Influence.dart';
import 'package:bandmates/views/ChatRoomScreen.dart';
import 'package:bandmates/views/PostScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:bandmates/views/UploadScreens/EventUploadScreen.dart';
import 'package:bandmates/views/UploadScreens/PostUploadScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/UI/PostItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../EditProfileScreen.dart';
import 'CustomNetworkImage.dart';
import '../../models/User.dart';
import 'package:line_icons/line_icons.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/Post.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import '../../Utils.dart';
import 'package:app_settings/app_settings.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class ProfileScreenBody extends StatefulWidget {
  final User user;
  ProfileScreenBody({@required this.user});

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with SingleTickerProviderStateMixin {
  User _currentUser;
  String _tempDir;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getTemporaryDirectory().then((d) => _tempDir = d.path);
    _currentUser = prefix0.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    print("[ProfileScreenBody] uid: " + widget.user.uid.toString());

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Row(
                  children: <Widget>[
                    CircularProfileAvatar(
                      widget.user.photoUrl != null
                          ? widget.user.photoUrl
                          : "https://w5insight.com/wp-content/uploads/2014/07/placeholder-user-400x400.png",
                      radius: 35,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      child: Text(
                        widget.user.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  LineIcons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text("Edit Profile"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => EditProfileScreen(
                                user: widget.user,
                              )));
                },
              ),
              ListTile(
                leading: Icon(
                  LineIcons.key,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text("Change Password"),
                onTap: () async {
                  ConfirmAction action = await showDialog<ConfirmAction>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Reset Password?"),
                          content: Text(
                              "You will recieve an email with a link to reset your password."),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop(ConfirmAction.CANCEL);
                              },
                            ),
                            FlatButton(
                              child: const Text('Send Link'),
                              onPressed: () {
                                Navigator.of(context).pop(ConfirmAction.ACCEPT);
                              },
                            )
                          ],
                        );
                      });

                  if (action == ConfirmAction.ACCEPT) {
                    FirebaseAuth.instance.sendPasswordResetEmail(
                        email: Provider.of<FirebaseUser>(context).email);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text("A password reset link sent to your email"),
                    ));
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  LineIcons.gear,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text("Settings"),
                onTap: () async {
                  await AppSettings.openAppSettings();

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  LineIcons.question,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text("Help & Feedback"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  LineIcons.sign_out,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text("Sign Out"),
                onTap: () {
                  Navigator.pop(context);

                  Provider.of<AuthService>(context).signOut();
                },
              )
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            buildHeader(),
            CustomScrollView(
              slivers: <Widget>[
                widget.user.uid == prefix0.currentUser.uid
                    ? SliverAppBar(
                        expandedHeight: 50,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              LineIcons.ellipsis_h,
                              size: 32,
                            ),
                            onPressed: () =>
                                _scaffoldKey.currentState.openEndDrawer(),
                          ),
                        ],
                      )
                    : SliverAppBar(
                        expandedHeight: 80,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              LineIcons.ellipsis_h,
                            ),
                            onPressed: () => print("Menu pressed!"),
                          )
                        ],
                      ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    buildProfileCard(),
                    buildInfoCard(),
                    _buildPostCard(context),
                  ]),
                ),
              ],
            ),
          ],
        ),
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
      height: 250,
      width: double.infinity,
      child: Container(),
    );
  }

  buildProfileCard() {
    return Stack(
      children: <Widget>[
        Wrap(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.only(top: 90),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(widget.user.bio),
                      SizedBox(
                        height: 8,
                      ),
                      widget.user.uid == _currentUser.uid
                          ? FittedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FlatButton.icon(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    color: Theme.of(context).primaryColor,
                                    icon: Icon(LineIcons.calendar),
                                    textColor: Colors.white,
                                    label: Text(
                                      "Create Event",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => Navigator.pushNamed(
                                        context, EventUploadScreen.routeName),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  FlatButton.icon(
                                    icon: Icon(LineIcons.music),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    label: Text(
                                      "Upload Post",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: () => Navigator.pushNamed(
                                        context, PostUploadScreen.routeName),
                                  ),
                                ],
                              ),
                            )
                          : FlatButton.icon(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(50)),
                              color: Theme.of(context).accentColor,
                              icon: Icon(LineIcons.comment),
                              textColor: Colors.white,
                              label: Text(
                                "Chat",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                DocumentSnapshot doc =
                                    await Provider.of<ChatProvider>(context)
                                        .getIndividualChat(
                                            _currentUser.uid,
                                            _currentUser.name,
                                            _currentUser.photoUrl,
                                            _currentUser.token,
                                            widget.user.uid,
                                            widget.user.name,
                                            widget.user.photoUrl,
                                            widget.user.token);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return ChatRoomScreen(
                                      chat: Chat.fromDocument(doc),
                                    );
                                  }),
                                );
                              }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: widget.user.photoUrl != null
                ? CircularProfileAvatar(
                    widget.user.photoUrl,
                    radius: 80,
                    borderColor: Colors.white,
                    borderWidth: 6,
                  )
                : CircularProfileAvatar(
                    "https://www.bsn.eu/wp-content/uploads/2016/12/user-icon-image-placeholder-300-grey.jpg",
                    radius: 80,
                    borderColor: Colors.white,
                    borderWidth: 3,
                  ),
          ),
        ),
      ],
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
          return Center(child: circularProgress(context));
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(25),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                      for (String inst in widget.user.instruments)
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
                      for (String genre in widget.user.genres)
                        Chip(
                          label: Text(genre),
                        )
                    ],
                  ),
                ),
                Divider(),
                Text(
                  "Influences",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                widget.user.influences != null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          runSpacing: 0,
                          spacing: 4,
                          children: [
                            for (String influence in widget.user.influences)
                              Chip(
                                label: Text(influence),
                              )
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "No influences to show",
                        ),
                      ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              prefix0.currentUser.uid == widget.user.uid
                  ? Text(
                      "Your Posts",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  : Text(
                      widget.user.name + "'s Posts",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
              Divider(),
              FutureBuilder<List<DocumentSnapshot>>(
                future: Provider.of<PostProvider>(context)
                    .getUsersPosts(widget.user.uid),
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress(context);
                  }

                  if (snapshot.data.length == 0) {
                    return Center(
                      child: Text("No posts to display"),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Unable to get users posts, please try again later"),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4),
                    itemBuilder: (BuildContext context, int index) {
                      Post post = Post.fromDocument(snapshot.data[index]);
                      if (post.type == 0) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(post: post),
                            ),
                          ),
                          child: GridTile(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(post
                                        .mediaUrl) // customNetworkImage(post.mediaUrl),
                                    ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        );
                      } else if (post.type == 1) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(post: post),
                            ),
                          ),
                          child: GridTile(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'assets/images/audio-placeholder.png'),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        );
                      } else if (post.type == 2) {
                        return FutureBuilder(
                          future: VideoThumbnail.thumbnailFile(
                            video: post.mediaUrl,
                            thumbnailPath: _tempDir,
                            imageFormat: ImageFormat.JPEG,
                            maxHeight: 100,
                            maxWidth: 100,
                            quality: 75,
                          ),
                          builder: (BuildContext context, snapshot) {
                            if (!snapshot.hasData) {
                              return circularProgress(context);
                            }

                            if (snapshot.hasError) {
                              return Container();
                            }

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostScreen(post: post),
                                ),
                              ),
                              child: GridTile(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(snapshot.data)),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
