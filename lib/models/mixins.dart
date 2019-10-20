import 'package:jammerz/constants/genres.dart';
import 'package:jammerz/constants/instruments.dart';

class GenresMixin {
  List<String> _genres;
  set genres(List<String> g) {
    if (!g.every((genre) => ALLOWED_GENRES.contains(genre))) {
      var missing = g.where((genre) => !ALLOWED_GENRES.contains(genre));

      throw new ArgumentError(missing);
    }

    _genres = g;
  }

  List<String> get genres {
    return _genres;
  }
}

class InstrumentsMixin {
  List<String> _instruments;
  set genres(List<String> i) {
    if (!i.every((instrument) => ALLOWED_INSTRUMENTS.contains(instrument))) {
      var missing =
          i.where((instrument) => !ALLOWED_INSTRUMENTS.contains(instrument));

      throw new ArgumentError(missing);
    }

    _instruments = i;
  }

  List<String> get genres {
    return _instruments;
  }
}
