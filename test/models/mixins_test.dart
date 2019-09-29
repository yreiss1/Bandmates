import 'package:flutter_test/flutter_test.dart';
import 'package:jammerz/constants/genres.dart';
import 'package:jammerz/constants/instruments.dart';
import 'package:jammerz/models/mixins.dart';

void main() {
  group("GenreMixin Tests", () {
    test('Genre setters deny non existent genre', () {
      final gMixin = GenresMixin();

      expect(() => gMixin.genres = ['foo'], throwsArgumentError);
    });

    test('Genre setters allow good genre', () {
      final gMixin = GenresMixin();
      gMixin.genres = [ALLOWED_GENRES[0]];
      expect(gMixin.genres, equals([ALLOWED_GENRES[0]]));
    });
  });
  group("InstrumentMixin Tests", () {
    test('Instrument setters deny non existent genre', () {
      final iMixin = InstrumentsMixin();

      expect(() => iMixin.genres = ['foo'], throwsArgumentError);
    });

    test('Genre setters allow good genre', () {
      final iMixin = InstrumentsMixin();
      iMixin.genres = [ALLOWED_INSTRUMENTS[0]];
      expect(iMixin.genres, equals([ALLOWED_INSTRUMENTS[0]]));
    });
  });
}
