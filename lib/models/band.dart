import 'package:jammerz/models/mixins.dart';
import 'package:meta/meta.dart';
import 'package:jammerz/models/user.dart';

enum POSITIONS { guitarist, drummer, basist, vocalist }

class Band with GenresMixin {
  Band({
    @required this.name,
  });

  final String name;
  final List<User> members = [];
  final List<String> influences = [];
  final List<POSITIONS> lookingFor = [];
}
