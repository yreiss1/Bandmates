import 'package:flutter_test/flutter_test.dart';
import 'package:jammerz/models/mixins.dart';

void main() {
  test('Genre setters deny non existent genre', () {
    final gMixin = GenreMixin();

    expect(gMixin.genres = ['foo'], throwsA(ArgumentError));
  });
}
