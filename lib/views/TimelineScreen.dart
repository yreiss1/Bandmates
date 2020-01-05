import 'package:bandmates/models/Event.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/views/MusiciansSearchScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/Post.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/views/HomeScreen.dart' as prefix0;
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/UI/PostItem.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../presentation/InstrumentIcons.dart';

import '../models/User.dart';

final usersRef = Firestore.instance.collection('users');

class TimelineScreen extends StatefulWidget {
  final User currentUser;

  TimelineScreen({this.currentUser});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool _isLoading = false;
  List<Post> _posts = [];
  List<String> _followingList = [];
  List<User> _userList;
  List<Event> _eventList;
  final Geoflutterfire geo = Geoflutterfire();
  final GeoFirePoint center = prefix0.currentUser.location;

  @override
  void initState() {
    super.initState();
    _userList = [];
    _eventList = [];
    getTimeline();
    //getFollowing();
  }

  Future<List<User>> getUsers() async {
    List<User> userList = [];

    var collectionReference = Firestore.instance.collection('users');
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(
            center: center, radius: 100, field: 'location', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        userList.add(User.fromDocument(doc));
      });
      print("[TimeLineScreen] length: " + userList.length.toString());
    });

    setState(() {
      _userList = userList;
    });
  }

  Future<List<Event>> getEvents() async {
    List<Event> eventList = [];

    var collectionReference = Firestore.instance.collection('events');

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(
            center: center, radius: 100, field: 'location', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        eventList.add(Event.fromDocument(doc));
      });
    });

    setState(() {
      _eventList = eventList;
    });
  }

  Future<void> getTimeline() async {
    setState(() {
      _isLoading = true;
    });
    List<Event> eventList = [];
    List<User> userList = [];

    var collectionReference = Firestore.instance.collection('events');

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: 100, field: 'loc', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        setState(() {
          _eventList.add(Event.fromDocument(doc));
        });
        //eventList.add(Event.fromDocument(doc));
      });
    });

    var userReference = Firestore.instance.collection('users');
    Stream<List<DocumentSnapshot>> userStream = geo
        .collection(collectionRef: userReference)
        .within(
            center: center, radius: 100, field: 'location', strictMode: true);

    userStream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) {
        setState(() {
          if (doc.documentID != prefix0.currentUser.uid) {
            _userList.add(User.fromDocument(doc));
          }
        });
      });
      print("[TimeLineScreen] length: " + userList.length.toString());
    });

    setState(() {
      //_userList = userList;
      //_eventList = eventList;
      _isLoading = false;
    });

    print("[TimeLineScreen] length again: " + userList.length.toString());
  }

  getFollowing() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("following")
        .document(widget.currentUser.uid)
        .collection("following")
        .getDocuments();

    setState(() {
      _followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          //.orderBy("time")
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }

        List<User> usersToFollow = [];

        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);

          final bool isAuthUser = widget.currentUser.uid == user.uid;
          final bool isFollowingUser = _followingList.contains(user.uid);

          if (isAuthUser || isFollowingUser) {
            return;
          } else {
            usersToFollow.add(user);
          }
        });

        return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      LineIcons.user_plus,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 0.0,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: usersToFollow.length,
                  itemBuilder: (context, index) {
                    User user = usersToFollow[index];
                    return ListTile(
                      onTap: () => Navigator.pushNamed(
                          context, ProfileScreen.routeName,
                          arguments: ProfileScreenArguments(userId: user.uid)),
                      title: Text(user.name),
                      subtitle: Text(buildSubtitle(user.instruments) +
                          "\n" +
                          user.location
                              .distance(
                                  lat: widget.currentUser.location.latitude,
                                  lng: widget.currentUser.location.longitude)
                              .round()
                              .toString() +
                          " kilometers away"),
                      isThreeLine: true,
                      enabled: true,
                      leading: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: user.photoUrl == null
                              ? AssetImage('assets/images/user-placeholder.png')
                              : NetworkImage(user.photoUrl),
                        ),
                        decoration: new BoxDecoration(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
            "\\");

    result = result.substring(1, result.length - 1);
    if (result.length > 40) {
      result = result.substring(0, 40);
      result += "...";
    }
    return result;
  }

  buildTimeline() {
    if (_posts == null) {
      return circularProgress(context);
    } else if (_posts.isEmpty) {
      return buildUsersToFollow();
    }

    return ListView.separated(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    print("[Timeline] Rebuilding the widget");

    return ListView(
      children: <Widget>[
        buildSearchHeader(),
        SizedBox(
          height: 16,
        ),
        buildMainArea(),
      ],
    );
  }

  buildSearchHeader() {
    final coordinates = new geocoder.Coordinates(
        prefix0.currentUser.location.latitude,
        prefix0.currentUser.location.longitude);

    return FutureBuilder<List<geocoder.Address>>(
      future: geocoder.Geocoder.local.findAddressesFromCoordinates(coordinates),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        return Container(
          padding: EdgeInsets.only(left: 12, top: 32),
          height: MediaQuery.of(context).size.height * 0.25,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Hello " + prefix0.currentUser.name + "!",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Your Set Location: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16)),
                  TextSpan(
                    text: snapshot.data.first.addressLine,
                    style: TextStyle(color: Colors.white),
                  )
                ]),
              ),
              SizedBox(
                height: 4,
              ),
              FlatButton.icon(
                  icon: Icon(LineIcons.map),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text("Change"),
                  textColor: Colors.white,
                  onPressed: () {}),
            ],
          ),
        );
      },
    );
  }

  buildEventsList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Events Near You",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                FlatButton(
                  onPressed: () {},
                  child: Text(
                    "See All",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(left: 12, right: 12),
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 16,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: _eventList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 10,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: 250,
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _eventList[index].title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    child: Text(
                                      _eventList[index].type == 0
                                          ? "Concert"
                                          : _eventList[index].type == 1
                                              ? "Audition"
                                              : "Jam Session",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(_eventList[index].name),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                height: 100,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: Card(
                                    elevation: 5,
                                    child: GoogleMap(
                                      scrollGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      myLocationButtonEnabled: false,
                                      mapType: MapType.normal,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            _eventList[index].location.latitude,
                                            _eventList[index]
                                                .location
                                                .longitude),
                                        zoom: 14.0000,
                                      ),
                                      markers: {
                                        Marker(
                                            markerId:
                                                MarkerId("Event Location"),
                                            position: LatLng(
                                                _eventList[index]
                                                    .location
                                                    .latitude,
                                                _eventList[index]
                                                    .location
                                                    .longitude))
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                _eventList[index].text,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                _eventList[index]
                                        .location
                                        .distance(
                                            lat: prefix0
                                                .currentUser.location.latitude,
                                            lng: prefix0
                                                .currentUser.location.longitude)
                                        .round()
                                        .toString() +
                                    " km away",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  buildUsersList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Musicians Near You",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                FlatButton(
                  onPressed: () => Navigator.pushNamed(
                      context, MusiciansSearchScreen.routeName),
                  child: Text(
                    "See All",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(left: 12, right: 12),
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 16,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: _userList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.32,
                  width: 134,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, ProfileScreen.routeName,
                                arguments: ProfileScreenArguments(
                                    userId: _userList[index].uid)),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 10,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: 134,
                                height:
                                    MediaQuery.of(context).size.height * 0.22,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 45,
                                    ),
                                    Text(
                                      _userList[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          InstrumentIcons.electric_guitar,
                                          size: 25,
                                        ),
                                        Icon(
                                          InstrumentIcons.drum_set,
                                          size: 25,
                                        ),
                                        Icon(
                                          InstrumentIcons.piano,
                                          size: 25,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      _userList[index]
                                              .location
                                              .distance(
                                                  lat: prefix0.currentUser
                                                      .location.latitude,
                                                  lng: prefix0.currentUser
                                                      .location.longitude)
                                              .round()
                                              .toString() +
                                          " km away",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: _userList[index].photoUrl == null
                            ? AssetImage("assets/images/user-placeholder.png")
                            : CachedNetworkImageProvider(
                                _userList[index].photoUrl),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  buildMainArea() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      height: MediaQuery.of(context).size.height * 0.95,
      width: double.infinity,
      child: _isLoading
          ? circularProgress(context)
          : Column(
              children: <Widget>[
                buildUsersList(),
                buildEventsList(),
              ],
            ),
    );
  }
}
