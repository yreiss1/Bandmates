import 'package:flutter/material.dart';
import 'package:bandmates/models/Follow.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/UI/PostItem.dart';
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
import '../ChatRoomScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreenBody extends StatefulWidget {
  final User user;
  ProfileScreenBody({@required this.user});

  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool _isFollowing = false;
  User _currentUser;
  int _followersCount = 0;
  int _postCount = 0;
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _currentUser = prefix0.currentUser;
    _getUserPosts();
    _checkIfFollowing();

    _getFollowers();
    _getFollowing();
  }

  _getFollowers() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("followers")
        .document(widget.user.uid)
        .collection("followers")
        .getDocuments();
    setState(() {
      _followersCount = snapshot.documents.length;
    });
  }

  _getFollowing() {}

  _checkIfFollowing() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection("following")
        .document(_currentUser.uid)
        .collection("following")
        .document(widget.user.uid)
        .get();

    setState(() {
      _isFollowing = doc.exists;
    });
  }

  _getUserPosts() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnap = await Firestore.instance
        .collection("posts")
        .document(widget.user.uid)
        .collection("userPosts")
        .orderBy("time", descending: true)
        .getDocuments();

    setState(() {
      _posts =
          querySnap.documents.map((doc) => Post.fromDocument(doc)).toList();
      _postCount = querySnap.documents.length;
      _isLoading = false;
    });
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

  Widget _buildDataRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              _followersCount.toString(),
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
              _postCount.toString(),
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
    );
  }

  unfollowUser() {
    setState(() {
      _isFollowing = false;
      _followersCount -= 1;
    });

    Provider.of<FollowProvider>(context).unfollowUser(
        usersId: widget.user.uid, currentUserId: _currentUser.uid);
    Firestore.instance
        .collection("feed")
        .document(widget.user.uid)
        .collection("feedItems")
        .document(_currentUser.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  followUser() {
    setState(() {
      _isFollowing = true;
      _followersCount += 1;
    });

    Provider.of<FollowProvider>(context)
        .followUser(usersId: widget.user.uid, currentUserId: _currentUser.uid);
    Firestore.instance
        .collection("feed")
        .document(widget.user.uid)
        .collection("feedItems")
        .document(_currentUser.uid)
        .setData({
      "type": 2,
      "ownerId": widget.user.uid,
      "user": _currentUser.name,
      "userId": _currentUser.uid,
      "avatar": _currentUser.photoUrl,
      "time": DateTime.now()
    });
  }

  @override
  Widget build(BuildContext context) {
    print("[ProfileScreenBody] uid: " + widget.user.uid.toString());

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.user.uid != _currentUser.uid
                      ? [
                          FloatingActionButton(
                            heroTag: 'chatBtn',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ChatRoomScreen(otherUser: widget.user);
                              }),
                            ),
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
                          _isFollowing == false
                              ? FloatingActionButton(
                                  heroTag: 'followBtn',
                                  onPressed: followUser,
                                  backgroundColor: Color(0xff829abe),
                                  child: Icon(LineIcons.user_plus),
                                )
                              : FloatingActionButton(
                                  heroTag: 'unfollowBtn',
                                  onPressed: unfollowUser,
                                  backgroundColor: Color(0xff829abe),
                                  child: Icon(LineIcons.trash),
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
                    if (widget.user.uid == _currentUser.uid)
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
                    _buildDataRow(),
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
          SizedBox(
            height: MediaQuery.of(context).size.height - 130,
            width: double.infinity,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _isLoading == false
                    ? _postCount == 0
                        ? Center(
                            child: Text("No posts to display"),
                          )
                        : ListView.separated(
                            itemBuilder: (context, index) {
                              return ChangeNotifierProvider.value(
                                value: _posts[index],
                                child: PostItem(
                                  currentUser: prefix0.currentUser,
                                  post: _posts[index],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[300],
                              thickness: 10,
                            ),
                            itemCount: _posts.length,
                          )
                    : PKCardListSkeleton(
                        isCircularImage: true,
                        length: 5,
                        isBottomLinesActive: true,
                      ),
                Text("Hello"),
                Text("Hello again"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
