import 'dart:math' as math;
import 'dart:typed_data';

/// Tiny original PCM WAVs generated at runtime — no bundled audio assets.
abstract final class SfxLibrary {
  static final Uint8List whoosh = _encode(_whoosh());
  static final Uint8List tap = _encode(_tap());
  static final Uint8List clear = _encode(_clear());

  static const sampleRate = 22050;

  static List<double> _whoosh() {
    final rng = math.Random(11);
    final n = (sampleRate * 0.28).round();
    var prev = 0.0;
    return List<double>.generate(n, (i) {
      final t = i / n;
      final env = t < 0.12 ? t / 0.12 : math.pow(1 - ((t - 0.12) / 0.88), 1.6);
      final noise = rng.nextDouble() * 2 - 1;
      final hp = noise - prev;
      prev = noise;
      return (hp * env * 0.55).clamp(-1.0, 1.0).toDouble();
    });
  }

  static List<double> _tap() {
    final n = (sampleRate * 0.09).round();
    return List<double>.generate(n, (i) {
      final t = i / sampleRate;
      final env = math.exp(-t * 38);
      return math.sin(2 * math.pi * 168 * t) * env * 0.45;
    });
  }

  static List<double> _clear() {
    final n = (sampleRate * 0.42).round();
    return List<double>.generate(n, (i) {
      final t = i / sampleRate;
      final a = math.exp(-t * 6) * math.sin(2 * math.pi * 523.25 * t);
      final b = t < 0.08
          ? 0.0
          : math.exp(-(t - 0.08) * 7) * math.sin(2 * math.pi * 659.25 * t);
      return ((a * 0.28) + (b * 0.32)).clamp(-1.0, 1.0);
    });
  }

  static Uint8List _encode(List<double> samples) {
    final dataLength = samples.length * 2;
    final bytes = ByteData(44 + dataLength);
    var o = 0;
    void ascii(String s) {
      for (var i = 0; i < s.length; i++) {
        bytes.setUint8(o++, s.codeUnitAt(i));
      }
    }

    void u16(int v) {
      bytes.setUint16(o, v, Endian.little);
      o += 2;
    }

    void u32(int v) {
      bytes.setUint32(o, v, Endian.little);
      o += 4;
    }

    ascii('RIFF');
    u32(36 + dataLength);
    ascii('WAVE');
    ascii('fmt ');
    u32(16);
    u16(1);
    u16(1);
    u32(sampleRate);
    u32(sampleRate * 2);
    u16(2);
    u16(16);
    ascii('data');
    u32(dataLength);
    for (final sample in samples) {
      final v = (sample.clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(o, v, Endian.little);
      o += 2;
    }
    return bytes.buffer.asUint8List();
  }
}
