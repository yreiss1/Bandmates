import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../presentation/InstrumentIcons.dart';

class InstrumentCapture extends StatelessWidget {
  GlobalKey<FormBuilderState> fbKey;

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
                          value: 'guitar',
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
                          value: 'piano',
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
                          value: 'bass',
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
                          value: 'drums',
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
                          value: 'flute',
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
                          value: 'harmonica',
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
                          value: 'violin',
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
                          value: 'ukelele',
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
                          value: 'banjo',
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
                          value: 'xylophone',
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
                          value: 'sax',
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
                          value: 'vocals',
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
                          value: 'accordion',
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
                          value: 'trumpet',
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
                          value: 'contrabass',
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
                          value: 'trombone',
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
                          value: 'DJ',
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
                          value: 'mandolin',
                        ),
                        FormBuilderFieldOption(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                InstrumentIcons.harp,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Harp")
                            ],
                          ),
                          value: 'harp',
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
