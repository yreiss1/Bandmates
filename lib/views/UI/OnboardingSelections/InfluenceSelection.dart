import 'package:bandmates/models/Influence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:xml2json/xml2json.dart';

class InfluenceSelection extends StatelessWidget {
  SwiperController swiperController;
  final Map<dynamic, dynamic> userData;

  InfluenceSelection({this.swiperController, this.userData});
  Xml2Json xml2json = new Xml2Json();

  List<Influence> _selectedInfluences = [];

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
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Your Influences",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  FlutterTagging<Influence>(
                    emptyBuilder: (context) {
                      return ListTile(
                        leading: Icon(Icons.not_interested),
                        title: Text("No Artist with that name exists"),
                      );
                    },
                    initialItems: _selectedInfluences,
                    hideOnEmpty: false,
                    textFieldConfiguration: TextFieldConfiguration(
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Search for your Influences",
                      ),
                    ),
                    findSuggestions: searchInfluence,
                    // additionCallback: (String value) {
                    //   return Influence(name: value);
                    // },
                    configureChip: (influence) {
                      return ChipConfiguration(
                        label: Text(influence.name),
                        backgroundColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white,
                      );
                    },
                    wrapConfiguration: WrapConfiguration(
                      spacing: 4,
                    ),
                    configureSuggestion: (influence) {
                      return SuggestionConfiguration(
                        title: Text(
                          influence.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: (influence.country == null &&
                                influence.date == null)
                            ? Text("")
                            : (influence.country == null &&
                                    influence.date != null)
                                ? Text(influence.date)
                                : (influence.date == null &&
                                        influence.country != null)
                                    ? Text(influence.country)
                                    : Text(influence.country +
                                        " - " +
                                        influence.date),
                      );
                    },
                    onChanged: () {
                      userData['influences'] = _selectedInfluences
                          .map((influence) => influence.name)
                          .toList();
                    },
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
                  FocusScope.of(context).unfocus();
                  swiperController.previous();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Influence>> searchInfluence(String query) async {
    if (query.isEmpty) {
      return [];
    }
    var url = "http://musicbrainz.org/ws/2/artist/?query=artist:" +
        query.replaceAll(' ', '%20');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      xml2json.parse(response.body);
      var jsonData = xml2json.toGData();
      var body = convert.json.decode(jsonData);

      List<Influence> influences = [];
      if (int.parse(body['metadata']['artist-list']['count']) > 1) {
        // print("[OnboardingScreen] JSON: " +
        //     body['metadata']['artist-list']['artist'][0].toString());

        influences = List<Influence>.from(body['metadata']['artist-list']
                ['artist']
            .map((x) => Influence.fromJson(x)));
      } else if (int.parse(body['metadata']['artist-list']['count']) == 0) {
        influences = [];
      } else {
        influences = [
          Influence.fromJson(body['metadata']['artist-list']['artist'])
        ];
        // print("[OnboardingScreen] JSON: " +
        //     body['metadata']['artist-list']['artist'].toString());
      }

      return influences;
    }

    return [];
  }
}
