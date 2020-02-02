import 'package:bandmates/models/Instrument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

import '../../../Utils.dart';

class InstrumentSelection extends StatelessWidget {
  final SwiperController swiperController;
  final Map<dynamic, dynamic> userData;
  InstrumentSelection({this.swiperController, this.userData});

  List<Instrument> _selectedInstruments = [];

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
                    "Instruments you play",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  FlutterTagging<Instrument>(
                    initialItems: _selectedInstruments,
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
                        hintText: "Search for your Instruments",
                      ),
                    ),
                    findSuggestions: searchInstruments,
                    configureChip: (inst) {
                      return ChipConfiguration(
                        label: Text(inst.name),
                        backgroundColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white,
                      );
                    },
                    wrapConfiguration: WrapConfiguration(
                      runSpacing: 4,
                      spacing: 4,
                    ),
                    configureSuggestion: (inst) {
                      return SuggestionConfiguration(
                        title: Text(inst.name),
                      );
                    },
                    onChanged: () {
                      userData['instruments'] = _selectedInstruments
                          .map((inst) => inst.name)
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
                  FocusScope.of(context).unfocus();

                  swiperController.next();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //TODO: Remove this
  Future<List<Instrument>> searchInstruments(String query) async {
    await Future.delayed(Duration(milliseconds: 300), null);
    return Utils.instrumentList
        .map((inst) => inst)
        .where((inst) => inst.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
