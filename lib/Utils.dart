import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/presentation/GenreIcons.dart';
import 'package:bandmates/presentation/InstrumentIcons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/user.dart';

class Utils {
  static final List<Instrument> instrumentList = [
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

  static final List<Genre> genresList = [
    Genre(name: "Rock", value: 'rock', icon: Icon(InstrumentIcons.amp)),
    Genre(name: "R&B", value: 'r&b', icon: Icon(GenreIcons.r_b)),
    Genre(name: "Metal", value: 'metal', icon: Icon(GenreIcons.metal)),
    Genre(name: "Blues", value: 'blues', icon: Icon(GenreIcons.blues)),
    Genre(
        name: "Blue Grass",
        value: 'bluegrass',
        icon: Icon(GenreIcons.bluegrass)),
    Genre(name: "Punk Rock", value: 'punk', icon: Icon(GenreIcons.punk)),
    Genre(
        name: "Classic Rock", value: 'classic', icon: Icon(GenreIcons.classic)),
    Genre(name: "Ska", value: 'trombone', icon: Icon(InstrumentIcons.trombone)),
    Genre(name: "Pop", value: 'pop', icon: Icon(GenreIcons.pop)),
    Genre(
        name: "Alternative Rock",
        value: 'alt',
        icon: Icon(GenreIcons.alternative)),
    Genre(name: "Arab", value: 'arab', icon: Icon(GenreIcons.arab)),
    Genre(
        name: "Classical",
        value: 'classical',
        icon: Icon(InstrumentIcons.musical_notes)),
    Genre(name: "Jazz", value: 'jazz', icon: Icon(GenreIcons.jazz)),
    Genre(name: "Rap", value: 'rap', icon: Icon(GenreIcons.rap)),
    Genre(name: "Reggae", value: 'reggae', icon: Icon(GenreIcons.reggae)),
    Genre(name: "Country", value: 'country', icon: Icon(GenreIcons.country)),
    Genre(name: "Latin", value: 'latin', icon: Icon(GenreIcons.latin)),
    Genre(name: "EDM", value: 'edm', icon: Icon(GenreIcons.electronic)),
    Genre(name: "Funk", value: 'funk', icon: Icon(GenreIcons.funk)),
    Genre(
        name: "Choir/Accapella", value: 'choir', icon: Icon(GenreIcons.choir)),
  ];

  static Future buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  static IconData valueToIcon(String value) {
    switch (value) {
      case "guitar":
        return InstrumentIcons.electric_guitar;
        break;
      case "bass":
        return InstrumentIcons.bass_guitar;
        break;
      case "drums":
        return InstrumentIcons.drum_set;
        break;
      case "piano":
        return InstrumentIcons.piano;
        break;
      case "flute":
        return InstrumentIcons.flute;
        break;
      case "harp":
        return InstrumentIcons.harp;
        break;
      case "harmonica":
        return InstrumentIcons.harmonica;
        break;
      case "violin":
        return InstrumentIcons.violin;
        break;
      case "ukelele":
        return InstrumentIcons.ukelele;
        break;
      case "xylophone":
        return InstrumentIcons.xylophone;
        break;
      case "saxaphone":
        return InstrumentIcons.saxophone;
        break;
      case "banjo":
        return InstrumentIcons.banjo;
        break;
      case "vocals":
        return InstrumentIcons.microphone;
        break;
      case "accordion":
        return InstrumentIcons.accordion;
        break;
      case "trumpet":
        return InstrumentIcons.trumpet;
        break;
      case "contrabass":
        return InstrumentIcons.contrabass;
        break;
      case "trombone":
        return InstrumentIcons.trombone;
        break;
      case "turntable":
        return InstrumentIcons.turntable;
        break;
      case "harp":
        return InstrumentIcons.harp;
        break;
      default:
        return InstrumentIcons.musical_notes;
    }
  }
}
