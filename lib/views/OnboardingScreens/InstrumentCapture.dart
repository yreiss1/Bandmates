import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../presentation/InstrumentIcons.dart';

class InstrumentCapture extends StatelessWidget {
  final GlobalKey<FormBuilderState> fbKey;

  InstrumentCapture({this.getInstruments, @required this.fbKey});
  final Function(List<dynamic> instruments) getInstruments;
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
                  fbKey.currentState.save(),
                  print(val),
                  getInstruments(val['instruments'])
                },
                key: fbKey,
                autovalidate: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderCheckboxList(
                      validators: [
                        (val) {
                          List<dynamic> arr = val as List<dynamic>;
                          if (arr.length == 0) {
                            return "";
                          }
                        }
                      ],
                      decoration: InputDecoration(
                          labelText: "Choose the instruments you play"),
                      attribute: "instruments",
                      checkColor: Theme.of(context).primaryColor,
                      activeColor: Colors.white,
                      options: [
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.electric_guitar,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Electric Guitar")
                            ],
                          ),
                          value: 1,
                        ),
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
                              Text("Piano")
                            ],
                          ),
                          value: 2,
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
                              Text("Bass Guitar")
                            ],
                          ),
                          value: 3,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.drum_set,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Drums")
                            ],
                          ),
                          value: 4,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.flute,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Flute")
                            ],
                          ),
                          value: 5,
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
                              Text("Harmonica")
                            ],
                          ),
                          value: 6,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.violin,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Violin")
                            ],
                          ),
                          value: 7,
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
                              Text("Ukelele")
                            ],
                          ),
                          value: 8,
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
                              Text("Banjo")
                            ],
                          ),
                          value: 9,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.xylophone,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Xylophone")
                            ],
                          ),
                          value: 10,
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
                              Text("Saxaphone")
                            ],
                          ),
                          value: 11,
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
                              Text("Vocals")
                            ],
                          ),
                          value: 12,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.accordion,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Accordion")
                            ],
                          ),
                          value: 13,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.trumpet,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Trumpet")
                            ],
                          ),
                          value: 14,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.contrabass,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Contrabass")
                            ],
                          ),
                          value: 15,
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
                              Text("Trombone")
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
                              Text("DJ/Turntable")
                            ],
                          ),
                          value: 17,
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.mandolin,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Mandolin")
                            ],
                          ),
                          value: 17,
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
