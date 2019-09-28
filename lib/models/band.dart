import 'package:meta/meta.dart';
import 'package:jammerz/models/user.dart';

enum POSITIONS { guitarist, drummer, basist, vocalist }

class Band {
  Band({
    @required this.name,
  });

  final String name;
  final List<User> members = [];
  final List<String> influences = [];
  final List<String> genres = [];
  final List<POSITIONS> lookingFor = [];
}
