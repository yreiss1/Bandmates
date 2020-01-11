import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/Event.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsSearchScreen extends StatefulWidget {
  static const routeName = '/events-search';

  @override
  _EventsSearchScreenState createState() => _EventsSearchScreenState();
}

class _EventsSearchScreenState extends State<EventsSearchScreen> {
  int _selectedType;
  String _selectedGenre;
  bool _searching = false;
  List<DropdownMenuItem> genres = [];
  List<Event> _eventsList = [];
  bool _isLoading = false;

  final GeoFirePoint center = currentUser.location;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Utils.genresList.forEach(
      (genre) => genres.add(
        DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Icon(
                genre.icon.icon,
                size: 40,
              ),
              SizedBox(
                width: 10,
              ),
              Text(genre.name)
            ],
          ),
          value: genre.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  buildSearchHeader(context),
                                  buildMainArea(context),
                                ],
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: 170,
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Chip(
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  label: TextField(
                                    onChanged: (value) {
                                      if (value.length > 3) {
                                        _searchName(value);
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
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ));
  }

  buildSearchHeader(context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 32),
      height: 200,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Search Events",
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
              label: DropdownButton(
                value: _selectedType,
                hint: Text("Event Type"),
                onChanged: (int value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _searchEvents();
                },
                items: [
                  DropdownMenuItem(
                    child: Text("Concert"),
                    value: 0,
                  ),
                  DropdownMenuItem(
                    child: Text("Audition"),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text("Jam Session"),
                    value: 2,
                  ),
                  DropdownMenuItem(
                    child: Text("Open Mic"),
                    value: 3,
                  )
                ],
              ),
            ),
          ),
          Transform(
            transform: new Matrix4.identity()..scale(0.9),
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.white,
              label: DropdownButton(
                value: _selectedGenre,
                hint: Text("Genre"),
                items: genres,
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value;
                  });
                  _searchEvents();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildMainArea(context) {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        child: _searching != true
            ? StreamBuilder(
                stream: Provider.of<EventProvider>(context).getClosest(center),
                builder: (BuildContext context,
                    AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasError) {
                    Utils.buildErrorDialog(context,
                        "There is an error fetching data, please try again later!");
                  }

                  if (!snapshot.hasData) {
                    return circularProgress(context);
                  }

                  if (snapshot.data.isEmpty) {
                    return Center(
                      child: Text(
                          "There are no current events near you at this time!"),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildEventCard(
                          Event.fromDocument(snapshot.data[index]));
                    },
                  );
                },
              )
            : _eventsList.isEmpty
                ? Center(
                    child: Text("No events with these parameters"),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: _eventsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildEventCard(_eventsList[index]);
                    },
                  ));
  }

  buildEventCard(Event event) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    event.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor)),
                    child: Text(
                      event.type == 0
                          ? "Concert"
                          : event.type == 1
                              ? "Audition"
                              : event.type == 2 ? "Jam Session" : "Open Mic",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text(event.name),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 150,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Card(
                    elevation: 5,
                    child: GoogleMap(
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            event.location.latitude, event.location.longitude),
                        zoom: 14.0000,
                      ),
                      markers: {
                        Marker(
                            markerId: MarkerId("Event Location"),
                            position: LatLng(event.location.latitude,
                                event.location.longitude))
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                event.text,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).accentColor)),
                child: Text(
                  DateFormat.yMMMd().add_jm().format(event.time),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                event.location
                        .distance(
                            lat: currentUser.location.latitude,
                            lng: currentUser.location.longitude)
                        .round()
                        .toString() +
                    " km away",
                style: TextStyle(
                    fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),
    );
  }

  _searchEvents() async {
    setState(() {
      _isLoading = true;
      _searching = true;
    });

    Query query = Firestore.instance.collection('events');

    if (_selectedType != null) {
      query = query.where("type", isEqualTo: _selectedType);
    }

    if (_selectedGenre != null) {
      query = query.where("genres.$_selectedGenre", isEqualTo: true);
    }

    QuerySnapshot snapshot = await query.getDocuments();

    List<Event> results = [];

    snapshot.documents.forEach((doc) {
      results.add(Event.fromDocument(doc));
    });

    setState(() {
      _eventsList = results;
      _isLoading = false;
    });
  }

  void _searchName(String query) async {
    setState(() {
      _isLoading = true;
      _searching = true;
    });
    List<Event> results = [];
    await Firestore.instance
        .collection('events')
        .where("title", isGreaterThanOrEqualTo: query.toUpperCase())
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) => results.add(Event.fromDocument(doc)));
    });

    setState(() {
      _eventsList = results;
      _isLoading = false;
    });
  }
}
