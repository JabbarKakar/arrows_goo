import 'dart:convert';

import 'package:arrows_goo/core/audio/sfx_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated sfx are PCM wavs', () {
    for (final bytes in [SfxLibrary.whoosh, SfxLibrary.tap, SfxLibrary.clear]) {
      expect(ascii.decode(bytes.sublist(0, 4)), 'RIFF');
      expect(ascii.decode(bytes.sublist(8, 12)), 'WAVE');
      expect(bytes.length, greaterThan(44));
    }
  });
}
