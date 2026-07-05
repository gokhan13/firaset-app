import 'dart:convert';
import 'dart:io';

import 'package:firaset/olcum/oran_hesaplayici.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fikstur_yukle.dart';

/// Golden'ı yeniden üretmek için:  UPDATE_GOLDEN=1 flutter test
const _fiksturler = ['yuz_dengeli', 'yuz_uzun', 'yuz_genis_agiz'];

void main() {
  const kodlayici = JsonEncoder.withIndent('  ');

  for (final ad in _fiksturler) {
    test('golden eşleşir: $ad', () {
      final vektor = hesapla(fiksturuYukle(ad));
      final uretilen = kodlayici.convert(vektor.toJson());
      final golden = File('test/golden/$ad.golden.json');

      if (Platform.environment['UPDATE_GOLDEN'] == '1') {
        golden.parent.createSync(recursive: true);
        golden.writeAsStringSync('$uretilen\n');
      }

      expect(
        golden.existsSync(),
        isTrue,
        reason: 'Golden yok; UPDATE_GOLDEN=1 ile üret.',
      );
      // Determinizm sözleşmesi: tam eşitlik (epsilon değil).
      expect(uretilen, golden.readAsStringSync().trimRight());
    });
  }

  test('determinizm: aynı girdi iki kez → bit-bit aynı vektör', () {
    final a = jsonEncode(hesapla(fiksturuYukle('yuz_dengeli')).toJson());
    final b = jsonEncode(hesapla(fiksturuYukle('yuz_dengeli')).toJson());
    expect(a, b);
  });
}
