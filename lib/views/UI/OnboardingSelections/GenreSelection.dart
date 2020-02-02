import 'package:bandmates/Utils.dart';
import 'package:bandmates/models/Genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class GenreSelection extends StatelessWidget {
  final SwiperController swiperController;
  final Map<dynamic, dynamic> userData;
  GenreSelection({this.swiperController, this.userData});

  List<Genre> _selectedGenres = [];

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
                    "Genres you play",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  FlutterTagging<Genre>(
                    initialItems: _selectedGenres,
                    debounceDuration: Duration(milliseconds: 100),
                    textFieldConfiguration: TextFieldConfiguration(
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColor,
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                        hintText: "Search for your Genres",
                      ),
                    ),
                    findSuggestions: searchGenres,
                    configureChip: (genre) {
                      return ChipConfiguration(
                        label: Text(genre.name),
                        backgroundColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white,
                      );
                    },
                    wrapConfiguration: WrapConfiguration(
                      runSpacing: 4,
                      spacing: 4,
                    ),
                    configureSuggestion: (genre) {
                      return SuggestionConfiguration(
                        title: Text(genre.name),
                      );
                    },
                    onChanged: () {
                      _selectedGenres.forEach((genre) {
                        userData['genres'].add(genre.name);
                      });
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
                  //FocusScope.of(context).unfocus();

                  swiperController.previous();
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.keyboard_arrow_down),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                label: Text(
                  "Next",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                onPressed: () {
                  //FocusScope.of(context).unfocus();

                  swiperController.next();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Genre>> searchGenres(String query) async {
    await Future.delayed(Duration(milliseconds: 300), null);
    return Utils.genresList
        .map((genre) => genre)
        .where(
            (genre) => genre.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
