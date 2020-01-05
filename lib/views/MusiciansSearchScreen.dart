import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/presentation/InstrumentIcons.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

final List<Instrument> instrumentList = [
  Instrument(
      name: "guitar",
      value: 'guitar',
      icon: Icon(InstrumentIcons.electric_guitar)),
  Instrument(name: "piano", value: 'piano', icon: Icon(InstrumentIcons.piano)),
  Instrument(
      name: "bass", value: 'bass', icon: Icon(InstrumentIcons.bass_guitar)),
  Instrument(
      name: "drums", value: 'drums', icon: Icon(InstrumentIcons.drum_set)),
  Instrument(name: "flute", value: 'flute', icon: Icon(InstrumentIcons.flute)),
  Instrument(
      name: "harmonica",
      value: 'harmonica',
      icon: Icon(InstrumentIcons.harmonica)),
  Instrument(
      name: "violin", value: 'violin', icon: Icon(InstrumentIcons.violin)),
  Instrument(
      name: "ukelele", value: 'ukelele', icon: Icon(InstrumentIcons.ukelele)),
  Instrument(name: "banjo", value: 'banjo', icon: Icon(InstrumentIcons.banjo)),
  Instrument(
      name: "xylophone",
      value: 'xylophone',
      icon: Icon(InstrumentIcons.xylophone)),
  Instrument(
      name: "saxophone", value: 'sax', icon: Icon(InstrumentIcons.saxophone)),
  Instrument(
      name: "vocals", value: 'vocals', icon: Icon(InstrumentIcons.microphone)),
  Instrument(
      name: "accordion",
      value: 'accordion',
      icon: Icon(InstrumentIcons.accordion)),
  Instrument(
      name: "trumpet", value: 'trumpet', icon: Icon(InstrumentIcons.trumpet)),
  Instrument(
      name: "contrabass",
      value: 'contrabass',
      icon: Icon(InstrumentIcons.contrabass)),
  Instrument(
      name: "trombone",
      value: 'trombone',
      icon: Icon(InstrumentIcons.trombone)),
  Instrument(
      name: "turntable",
      value: 'turntable',
      icon: Icon(InstrumentIcons.turntable)),
  Instrument(
      name: "mandolin",
      value: 'mandolin',
      icon: Icon(InstrumentIcons.mandolin)),
  Instrument(name: "harp", value: 'harp', icon: Icon(InstrumentIcons.harp)),
];

class MusiciansSearchScreen extends StatefulWidget {
  static const routeName = '/musicians-search';

  @override
  _MusiciansSearchScreenState createState() => _MusiciansSearchScreenState();
}

class _MusiciansSearchScreenState extends State<MusiciansSearchScreen> {
  String selectedGenre;
  String selectedInstrument;
  List<DropdownMenuItem> instruments = [];
  List<DropdownMenuItem> genres = [];
  List<User> _usersList = [];

  @override
  void initState() {
    super.initState();

    instrumentList.forEach((inst) => instruments.add(DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Icon(
                inst.icon.icon,
                size: 40,
              ),
              SizedBox(
                width: 10,
              ),
              Text(inst.name)
            ],
          ),
          value: inst.value,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  buildSearchHeader(context),
                  buildMainArea(context),
                ],
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Chip(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    label: TextField(
                      onChanged: (value) {
                        if (value.length > 3) {
                          searchName(value);
                        }
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                          hintText: "Search by name"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future<List<User>> searchUsers() async {
    return [currentUser];
    //Firestore.instance.collection("users").where().limit(50);
  }

  buildSearchHeader(context) {
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
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  LineIcons.long_arrow_left,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Search Musicians",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ],
          ),
          SizedBox(
            height: 24,
          ),
          buildChipInputs()
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.95,
        width: double.infinity,
        child: ListView.builder(
          itemCount: _usersList.length,
          itemBuilder: (BuildContext context, int index) {
            return buildUserCard(_usersList[index]);
          },
        ));
  }

  buildChipInputs() {
    return Container(
      height: 50,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: SearchableDropdown(
                value: selectedInstrument,
                hint: Text("Instrument"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    selectedInstrument = value;
                  });
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: SearchableDropdown(
                value: selectedGenre,
                hint: Text("Genre"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    selectedGenre = value;
                  });
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: SearchableDropdown(
                hint: Text("Transportation"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    selectedInstrument = value;
                  });
                },
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: SearchableDropdown(
                hint: Text("Practice Space"),
                items: instruments,
                onChanged: (value) {
                  setState(() {
                    selectedInstrument = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<User>> searchName(String query) async {
    List<User> results = [];
    await Firestore.instance
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: query.toUpperCase())
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) => results.add(User.fromDocument(doc)));
    });

    setState(() {
      _usersList = results;
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
            "\\");

    result = result.substring(1, result.length - 1);
    if (result.length > 40) {
      result = result.substring(0, 40);
      result += "...";
    }
    return result;
  }
}

buildUserCard(User user) {
  return Container(
    padding: EdgeInsets.all(4),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: user.photoUrl == null
                      ? AssetImage('assets/images/user-placeholder.png')
                      : CachedNetworkImageProvider(user.photoUrl),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(user.bio),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                for (String inst in user.instruments.keys)
                  Chip(
                    label: Text(inst),
                  )
              ],
            ),
            Row(
              children: <Widget>[
                for (String genre in user.genres.keys)
                  Chip(
                    label: Text(genre),
                  )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
