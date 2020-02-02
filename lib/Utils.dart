import 'dart:io';

import 'package:bandmates/models/Genre.dart';
import 'package:bandmates/models/Influence.dart';
import 'package:bandmates/models/Instrument.dart';
import 'package:bandmates/presentation/GenreIcons.dart';
import 'package:bandmates/presentation/InstrumentIcons.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:xml2json/xml2json.dart';
import 'package:image/image.dart' as Im;
import 'package:intl/intl.dart';

class Utils {
  static final List<Instrument> instrumentList = [
    Instrument(
        name: "Guitar",
        value: 'guitar',
        icon: Icon(InstrumentIcons.acoustic_guitar)),
    Instrument(
        name: "Acoustic Guitar",
        value: 'acoustic guitar',
        icon: Icon(InstrumentIcons.acoustic_guitar)),
    Instrument(
        name: "Electric Guitar",
        value: 'electric guitar',
        icon: Icon(InstrumentIcons.electric_guitar)),
    Instrument(
        name: "Piano", value: 'piano', icon: Icon(InstrumentIcons.piano)),
    Instrument(
        name: "Bass", value: 'bass', icon: Icon(InstrumentIcons.bass_guitar)),
    Instrument(
        name: "Drums", value: 'drums', icon: Icon(InstrumentIcons.drum_set)),
    Instrument(
        name: "Flute", value: 'flute', icon: Icon(InstrumentIcons.flute)),
    Instrument(
        name: "Harmonica",
        value: 'harmonica',
        icon: Icon(InstrumentIcons.harmonica)),
    Instrument(
        name: "Violin", value: 'violin', icon: Icon(InstrumentIcons.violin)),
    Instrument(
        name: "Ukelele", value: 'ukelele', icon: Icon(InstrumentIcons.ukelele)),
    Instrument(
        name: "Banjo", value: 'banjo', icon: Icon(InstrumentIcons.banjo)),
    Instrument(
        name: "Xylophone",
        value: 'xylophone',
        icon: Icon(InstrumentIcons.xylophone)),
    Instrument(
        name: "Saxophone", value: 'sax', icon: Icon(InstrumentIcons.saxophone)),
    Instrument(
        name: "Vocals",
        value: 'vocals',
        icon: Icon(InstrumentIcons.microphone)),
    Instrument(
        name: "Accordion",
        value: 'accordion',
        icon: Icon(InstrumentIcons.accordion)),
    Instrument(
        name: "Trumpet", value: 'trumpet', icon: Icon(InstrumentIcons.trumpet)),
    Instrument(
        name: "Contrabass",
        value: 'contrabass',
        icon: Icon(InstrumentIcons.contrabass)),
    Instrument(
        name: "Trombone",
        value: 'trombone',
        icon: Icon(InstrumentIcons.trombone)),
    Instrument(
        name: "Turntable",
        value: 'turntable',
        icon: Icon(InstrumentIcons.turntable)),
    Instrument(
        name: "Mandolin",
        value: 'mandolin',
        icon: Icon(InstrumentIcons.mandolin)),
    Instrument(name: "Harp", value: 'harp', icon: Icon(InstrumentIcons.harp)),
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

  static String deserializeEventType(int value) {
    switch (value) {
      case 0:
        return "Concert";
        break;
      case 1:
        return "Audition";
        break;
      case 2:
        return "Jam Session";
        break;
      case 3:
        return "Open Mic";
        break;
      default:
        return "Unkown";
    }
  }

  static IconData valueToIcon(String value) {
    switch (value) {
      case "Guitar":
        return InstrumentIcons.electric_guitar;
        break;
      case "Acoustic Guitar":
        return InstrumentIcons.acoustic_guitar;
        break;
      case "Electric Guitar":
        return InstrumentIcons.electric_guitar_2;
        break;
      case "Bass":
        return InstrumentIcons.bass_guitar;
        break;
      case "Drums":
        return InstrumentIcons.drum_set;
        break;
      case "Piano":
        return InstrumentIcons.piano;
        break;
      case "Flute":
        return InstrumentIcons.flute;
        break;
      case "Harp":
        return InstrumentIcons.harp;
        break;
      case "Harmonica":
        return InstrumentIcons.harmonica;
        break;
      case "Violin":
        return InstrumentIcons.violin;
        break;
      case "Ukelele":
        return InstrumentIcons.ukelele;
        break;
      case "Xylophone":
        return InstrumentIcons.xylophone;
        break;
      case "Saxaphone":
        return InstrumentIcons.saxophone;
        break;
      case "Banjo":
        return InstrumentIcons.banjo;
        break;
      case "Vocals":
        return InstrumentIcons.microphone;
        break;
      case "Accordion":
        return InstrumentIcons.accordion;
        break;
      case "Trumpet":
        return InstrumentIcons.trumpet;
        break;
      case "Contrabass":
        return InstrumentIcons.contrabass;
        break;
      case "Trombone":
        return InstrumentIcons.trombone;
        break;
      case "Turntable":
        return InstrumentIcons.turntable;
        break;
      case "Harp":
        return InstrumentIcons.harp;
        break;
      default:
        return null;
    }
  }

  static Future<List<Influence>> searchInfluence(String query) async {
    Xml2Json xml2json = new Xml2Json();

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

  static Future<File> compressImage(File selectedFile, String uid) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(selectedFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$uid.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    return compressedImageFile;
  }

  static String formateDateTime(DateTime start, DateTime end) {
    if (end == null) {
      return DateFormat.jm().add_yMEd().format(start) + ' - Whenever';
    }
    if (start.year == end.year) {
      if (start.month == end.month) {
        if (start.day == end.day) {
          return DateFormat.jm().format(start) +
              ' - ' +
              DateFormat.jm().add_yMEd().format(end);
        } else {
          return DateFormat.jm().add_MEd().format(start) +
              ' - ' +
              DateFormat.jm().add_yMEd().format(end);
        }
      } else {
        return DateFormat.jm().add_MEd().format(start) +
            ' - ' +
            DateFormat.jm().add_yMEd().format(end);
      }
    } else {
      return DateFormat.jm().add_yMEd().format(start) +
          ' - ' +
          DateFormat.jm().add_yMEd().format(end);
    }
  }
}
