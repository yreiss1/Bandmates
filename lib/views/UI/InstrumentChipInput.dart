import 'package:flutter/material.dart';
import '../../models/Instrument.dart';
import '../../presentation/InstrumentIcons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class InstrumentChipInput extends StatelessWidget {
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

  final GlobalKey<FormBuilderState> fbKey;
  final String label;
  final int maxChips;

  InstrumentChipInput({this.fbKey, this.label, this.maxChips = 1});

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

  @override
  Widget build(BuildContext context) {
    child:
    FormBuilderChipsInput(
      valueTransformer: (value) {
        for (Instrument instrument in instruments) {
          if (value == instrument.value) {
            return InputChip(
              key: ObjectKey(instrument),
              label: Text(instrument.value),
              avatar: instrument.instrumentIcon,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }
        }
        return null;
      },
      inputType: TextInputType.text,
      obscureText: false,
      autocorrect: false,
      keyboardAppearance: Brightness.light,
      textCapitalization: TextCapitalization.none,
      inputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      attribute: "instrument",
      findSuggestions: (query) => searchInstruments(query),
      maxChips: this.maxChips,
      validators: [FormBuilderValidators.required()],
      suggestionsBoxMaxHeight: 200,
      chipBuilder: (context, state, profile) {
        return InputChip(
          key: ObjectKey(profile),
          label: Text(profile.instrumentName),
          onDeleted: () => state.deleteChip(profile),
          avatar: profile.instrumentIcon,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, profile) {
        return ListTile(
          key: ObjectKey(profile),
          leading: profile.instrumentIcon,
          title: Text(profile.instrumentName),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }
}
