import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class Instrument {
  Instrument({@required this.name, @required this.proficency});

  final String name;
  final int proficency;
}
