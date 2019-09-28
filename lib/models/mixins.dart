import 'package:jammerz/constants/genres.dart';

class GenreMixin {
  set genres(List<String> g) {
    if (!g.every((genre) => ALLOWED_GENRES.contains(genre))) {
      var missing = g.where((genre) => !ALLOWED_GENRES.contains(genre));

      throw new ArgumentError("$missing are not valid genres");
    }

    genres = g;
  }

  List<String> get genres {
    return genres;
  }
}
