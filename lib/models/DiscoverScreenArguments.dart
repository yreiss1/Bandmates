import 'package:jammerz/models/Instrument.dart';

class DiscoverScreenArguments {
  Instrument instrument;
  final bool transportation;
  final bool practiceSpace;
  final double radius;
  //TODO: Add Location

  DiscoverScreenArguments(
      {this.instrument, this.transportation, this.practiceSpace, this.radius});
}
