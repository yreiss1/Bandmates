import 'package:bandmates/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/DiscoverScreenArguments.dart';
import 'package:bandmates/models/ProfileScreenArguments.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/presentation/GenreIcons.dart';
import 'package:bandmates/views/DiscoverScreen.dart';
import 'package:bandmates/views/ProfileScreen.dart';
import 'package:bandmates/views/TimelineScreen.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../presentation/InstrumentIcons.dart';
import '../models/Instrument.dart';
import '../models/Genre.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

class SearchScreen extends StatefulWidget {
  static final String routeName = '/search-screen';

  final User currentUser;
  SearchScreen({this.currentUser});

  static final GlobalKey<FormBuilderState> searchKey =
      GlobalKey<FormBuilderState>(debugLabel: 'SearchScreen');

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  bool isVisible;
  final List<Instrument> instruments = [
    Instrument(
        name: "guitar",
        value: 'guitar',
        icon: Icon(InstrumentIcons.electric_guitar)),
    Instrument(
        name: "piano", value: 'piano', icon: Icon(InstrumentIcons.piano)),
    Instrument(
        name: "bass", value: 'bass', icon: Icon(InstrumentIcons.bass_guitar)),
    Instrument(
        name: "drums", value: 'drums', icon: Icon(InstrumentIcons.drum_set)),
    Instrument(
        name: "flute", value: 'flute', icon: Icon(InstrumentIcons.flute)),
    Instrument(
        name: "harmonica",
        value: 'harmonica',
        icon: Icon(InstrumentIcons.harmonica)),
    Instrument(
        name: "violin", value: 'violin', icon: Icon(InstrumentIcons.violin)),
    Instrument(
        name: "ukelele", value: 'ukelele', icon: Icon(InstrumentIcons.ukelele)),
    Instrument(
        name: "banjo", value: 'banjo', icon: Icon(InstrumentIcons.banjo)),
    Instrument(
        name: "xylophone",
        value: 'xylophone',
        icon: Icon(InstrumentIcons.xylophone)),
    Instrument(
        name: "saxophone", value: 'sax', icon: Icon(InstrumentIcons.saxophone)),
    Instrument(
        name: "vocals",
        value: 'vocals',
        icon: Icon(InstrumentIcons.microphone)),
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

  @override
  void initState() {
    super.initState();

    isVisible = true;

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {
          setState(() {
            isVisible = false;
          });
        } else {
          setState(() {
            isVisible = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Instrument> searchInstruments(String query) {
    List<Instrument> results = [];
    for (Instrument instrument in instruments) {
      if (instrument.instrumentName.contains(query.toLowerCase()) ||
          query.toLowerCase().contains(instrument.instrumentName)) {
        results.add(instrument);
      }
    }

    return results;
  }

  List<Genre> searchGenres(String query) {
    List<Genre> results = [];
    for (Genre genre in Utils.genresList) {
      if (genre.genreName.contains(query.toLowerCase()) ||
          query.toLowerCase().contains(genre.genreName)) {
        results.add(genre);
      }
    }

    return results;
  }

  Future<List<User>> handleSearch(String query) async {
    List<User> results = [];
    await usersRef
        .where("name", isGreaterThanOrEqualTo: query.toUpperCase())
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) => results.add(User.fromDocument(doc)));
    });

    return results;
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

  _showAlert(context) {
    Alert(
      context: context,
      closeFunction: () => {},
      buttons: [],
      title: "Discover Artists",
      content: SafeArea(
        top: false,
        child: Container(
          child: FormBuilder(
            key: SearchScreen.searchKey,
            child: Column(
              children: <Widget>[
                // FormBuilderChipsInput(
                //   inputType: TextInputType.text,
                //   obscureText: false,
                //   autocorrect: false,
                //   keyboardAppearance: Brightness.light,
                //   textCapitalization: TextCapitalization.none,
                //   inputAction: TextInputAction.done,
                //   decoration: InputDecoration(labelText: "Instruments"),
                //   attribute: "instrument",
                //   findSuggestions: (query) => searchInstruments(query),
                //   maxChips: 1,
                //   validators: [FormBuilderValidators.required()],
                //   suggestionsBoxMaxHeight: 200,
                //   chipBuilder: (context, state, profile) {
                //     return InputChip(
                //       key: ObjectKey(profile),
                //       label: Text(profile.instrumentName),
                //       onDeleted: () => state.deleteChip(profile),
                //       avatar: profile.instrumentIcon,
                //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     );
                //   },
                //   suggestionBuilder: (context, state, profile) {
                //     return ListTile(
                //       key: ObjectKey(profile),
                //       leading: profile.instrumentIcon,
                //       title: Text(profile.instrumentName),
                //       onTap: () => state.selectSuggestion(profile),
                //     );
                //   },
                // ),
                FormBuilderCheckbox(
                  activeColor: Colors.white,
                  checkColor: Theme.of(context).primaryColor,
                  attribute: 'transportation',
                  label: Text("Has transportation"),
                ),
                FormBuilderCheckbox(
                  activeColor: Colors.white,
                  checkColor: Theme.of(context).primaryColor,
                  attribute: 'practice_space',
                  label: Text("Has practice space"),
                ),
                FormBuilderSlider(
                  initialValue: 20.0,
                  min: 0.0,
                  max: 100.0,
                  divisions: 10,
                  activeColor: Theme.of(context).primaryColor,
                  attribute: "distance",
                  decoration: InputDecoration(labelText: "Distance (Miles)"),
                ),
                DialogButton(
                    child: Text(
                      "Search",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      if (SearchScreen.searchKey.currentState
                          .saveAndValidate()) {
                        /*
                        print(SearchScreen
                            ._fbKey.currentState.value['instruments']);
                        print(SearchScreen._fbKey.currentState.value['genres']);
                        print(SearchScreen
                            ._fbKey.currentState.value['transportation']);
                        print(SearchScreen
                            ._fbKey.currentState.value['practice_space']);
                        print(
                            SearchScreen._fbKey.currentState.value['distance']);
                            */
                        Navigator.pop(context);
                        Navigator.pushNamed(context, DiscoverScreen.routeName,
                            arguments: DiscoverScreenArguments(
                              instrument: SearchScreen.searchKey.currentState
                                  .value['instrument'][0],
                              transportation: SearchScreen.searchKey
                                  .currentState.value['transportation'],
                              practiceSpace: SearchScreen.searchKey.currentState
                                  .value['practice_space'],
                              radius: SearchScreen
                                  .searchKey.currentState.value['distance'],
                            ));
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    radius: BorderRadius.circular(0.0)),
              ],
            ),
          ),
        ),
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    print("[SearchScreen] Rebuilding the widget");

    return Scaffold(
      floatingActionButton: isVisible
          ? FloatingActionButton.extended(
              icon: Icon(LineIcons.rocket),
              label: Text("Discover"),
              onPressed: () => _showAlert(context),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: ListView(
          children: <Widget>[buildSearchHeader(), buildMainArea()],
        ),
      ),
    );
  }

  buildSearchHeader() {
    return Container(
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: 100,
      color: Theme.of(context).primaryColor,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Chats",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }

  buildMainArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 100,
      child: Stack(
        children: <Widget>[
          SearchBar<User>(
            emptyWidget: Center(
              child: Text("No Results"),
            ),
            cancellationText: Text("Clear"),
            iconActiveColor: Theme.of(context).primaryColor,
            shrinkWrap: true,
            onSearch: (String text) => handleSearch(text),
            searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
            headerPadding: EdgeInsets.all(10),
            listPadding: EdgeInsets.symmetric(horizontal: 10),
            placeHolder: Center(
              child: Text("Start typing to search for users!"),
            ),
            debounceDuration: Duration(milliseconds: 400),
            loader: PKCardListSkeleton(
              isCircularImage: true,
              isBottomLinesActive: false,
            ),
            hintText: "Search for a user or band",
            buildSuggestion: (User user, int index) {
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                enabled: true,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photoUrl == null
                      ? AssetImage('assets/images/user-placeholder.png')
                      : NetworkImage(user.photoUrl),
                ),
                onTap: () => Navigator.pushNamed(
                    context, ProfileScreen.routeName,
                    arguments: ProfileScreenArguments(userId: user.uid)),
              );
            },
            crossAxisSpacing: 10,
            onItemFound: (User user, int index) {
              return Container(
                  child: Column(
                children: <Widget>[
                  ListTile(
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
                  ),
                  Divider(),
                ],
              ));
            },
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[],
            ),
          ),
        ],
      ),
    );
  }
}
