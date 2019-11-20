import 'package:flutter/material.dart';
import '../presentation/InstrumentIcons.dart';

class Instrument {
  final String name;
  final String value;
  final Icon icon;

  Instrument({this.name, this.value, this.icon});

  String get instrumentName => this.name;

  String get instrumentValue => this.value;

  Icon get instrumentIcon => this.icon;
}

final List<Instrument> instruments = [
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
