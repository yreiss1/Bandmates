import 'package:flutter/material.dart';
import 'package:jammerz/AuthService.dart';
import 'package:jammerz/views/UI/Progress.dart';
import '../../models/User.dart';
import 'package:line_icons/line_icons.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../UploadScreens/EventUploadScreen.dart';
import '../UploadScreens/PostUploadScreen.dart';
import '../../models/Post.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

class ProfileScreenBody extends StatefulWidget {
  final User user;
  ProfileScreenBody({@required this.user});

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
  }

  String buildSubtitle(Map<dynamic, dynamic> map) {
    List l = map.keys.toList();

    String result = l.fold(
        "",
        (inc, ins) =>
            inc +
            " " +
            ins.toString()[0].toUpperCase() +
            ins.toString().substring(1) +
            " " +
            "\·");

    result = result.substring(1, result.length - 1);
    /*
    if (result.length > 50) {
      result = result.substring(0, 50);
      result += "...";
    }
    */
    return result;
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
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.user.uid !=
                          Provider.of<UserProvider>(context, listen: false)
                              .currentUser
                              .uid
                      ? [
                          FloatingActionButton(
                            heroTag: 'chatBtn',
                            onPressed: () {},
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(LineIcons.comments),
                          ),
                          CircularProfileAvatar(
                            widget.user.photoUrl == null
                                ? "https://www.bsn.eu/wp-content/uploads/2016/12/user-icon-image-placeholder-300-grey.jpg"
                                : widget.user.photoUrl,
                            cacheImage: true,
                            radius: 70,
                          ),
                          FloatingActionButton(
                            heroTag: 'followBtn',
                            onPressed: () {},
                            backgroundColor: Color(0xff829abe),
                            child: Icon(LineIcons.user_plus),
                          ),
                        ]
                      : [
                          CircularProfileAvatar(
                            widget.user.photoUrl == null
                                ? "https://www.bsn.eu/wp-content/uploads/2016/12/user-icon-image-placeholder-300-grey.jpg"
                                : widget.user.photoUrl,
                            cacheImage: true,
                            radius: 70,
                          ),
                        ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      widget.user.name,
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff1d1e2c),
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * .9,
                      child: Text(
                        buildSubtitle(widget.user.instruments),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    /*
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "About Me:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Text(widget.user.bio),
                      ],
                    ),
                    */
                    if (widget.user.uid ==
                        Provider.of<UserProvider>(context, listen: false)
                            .currentUser
                            .uid)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton.icon(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(50)),
                            color: Theme.of(context).primaryColor,
                            icon: Icon(LineIcons.calendar),
                            textColor: Colors.white,
                            label: Text("Add Event"),
                            onPressed: () => Navigator.pushNamed(
                                context, EventUploadScreen.routeName),
                          ),
                          FlatButton.icon(
                            icon: Icon(LineIcons.file_text_o),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(50)),
                            label: Text("Add Post"),
                            textColor: Theme.of(context).primaryColor,
                            onPressed: () => Navigator.pushNamed(
                                context, PostUploadScreen.routeName),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              widget.user.followers.toString(),
                              style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            ),
                            Text('Followers')
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '245',
                              style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            ),
                            Text('Posts')
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '35',
                              style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            ),
                            Text('Yrs Playing')
                          ],
                        )
                      ],
                    ),
                    Divider(),
                  ],
                )
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            labelPadding: EdgeInsets.symmetric(horizontal: 20),
            isScrollable: true,
            tabs: <Widget>[
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 4.25,
                child: Icon(
                  LineIcons.trophy,
                  size: 40,
                ),
                alignment: Alignment.center,
              ),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 4.25,
                child: Icon(
                  LineIcons.bank,
                  size: 40,
                ),
                alignment: Alignment.center,
              ),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 4.25,
                child: Icon(
                  LineIcons.angellist,
                  size: 40,
                ),
                alignment: Alignment.center,
              ),
            ],
          ),
          Divider(),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 500,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                FutureBuilder<List<Post>>(
                  future: Provider.of<PostProvider>(context)
                      .getUsersPosts(widget.user.uid),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ListView(
                          children: snapshot.data
                              .map((post) => Card(
                                    child: Column(
                                      children: <Widget>[
                                        if (post.text != null) Text(post.text),
                                        if (post.time != null)
                                          Text(post.time.toString()),
                                        if (post.location != null)
                                          Text(post.location)
                                      ],
                                    ),
                                  ))
                              .toList());
                    } else if (snapshot.connectionState ==
                            ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.active) {
                      return PKCardListSkeleton(
                        isCircularImage: true,
                        isBottomLinesActive: false,
                      );
                    }
                  },
                ),
                Text("Goodbye"),
                Text("You again?")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
