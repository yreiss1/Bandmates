import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../presentation/InstrumentIcons.dart';

class GenreCapture extends StatelessWidget {
  final GlobalKey<FormBuilderState> fbKey;

  GenreCapture({this.getGenres, @required this.fbKey});

  final Function(List<dynamic> genres) getGenres;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              FormBuilder(
                onChanged: (val) => {
                  print(val),
                  fbKey.currentState.save(),
                  getGenres(val['genres'])
                },
                key: fbKey,
                child: Column(
                  children: <Widget>[
                    FormBuilderCheckboxList(
                      decoration: InputDecoration(
                          labelText: "Choose the genres you play"),
                      attribute: "genres",
                      checkColor: Theme.of(context).primaryColor,
                      activeColor: Colors.white,
                      options: [
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.piano,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("R&B")
                            ],
                          ),
                          value: 1,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.electric_guitar_2,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Metal")
                            ],
                          ),
                          value: 2,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.harmonica,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Blues")
                            ],
                          ),
                          value: 3,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.banjo,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Blue Grass")
                            ],
                          ),
                          value: 4,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.bass_guitar,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Punk Rock")
                            ],
                          ),
                          value: 5,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.acoustic_guitar,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Classic Rock")
                            ],
                          ),
                          value: 6,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.trombone,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Ska")
                            ],
                          ),
                          value: 7,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.microphone,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Pop")
                            ],
                          ),
                          value: 8,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.electric_guitar_1,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Alt Rock")
                            ],
                          ),
                          value: 9,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.amplificator,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Arab")
                            ],
                          ),
                          value: 10,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.score,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Classical")
                            ],
                          ),
                          value: 11,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.saxophone,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Jazz")
                            ],
                          ),
                          value: 12,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.microphone,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Rap")
                            ],
                          ),
                          value: 13,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.ukelele,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Reggae")
                            ],
                          ),
                          value: 14,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.banjo,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Country")
                            ],
                          ),
                          value: 15,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.conga,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Latin")
                            ],
                          ),
                          value: 16,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.turntable,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("EDM")
                            ],
                          ),
                          value: 17,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.bass_guitar,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Funk")
                            ],
                          ),
                          value: 18,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.score,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Choir/Accapella")
                            ],
                          ),
                          value: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
