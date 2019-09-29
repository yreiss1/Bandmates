import 'package:jammerz/models/mixins.dart';
import 'package:meta/meta.dart';

import 'package:geolocator/geolocator.dart';
import 'package:jammerz/models/instrument.dart';

enum PRAC_SPACE_OPTIONS { yes, no, maybe }

class User with GenresMixin, InstrumentsMixin {
  User(
      {@required this.email,
      @required this.name,
      @required this.age,
      @required this.practiceSpace,
      @required this.transportation});

  final String name;
  final String email;
  final String age;
  final List<String> gear = [];
  final List<Instrument> instruments = [];

  // Clips

  final PRAC_SPACE_OPTIONS practiceSpace;
  final bool transportation;

  final Position location = null;
}
