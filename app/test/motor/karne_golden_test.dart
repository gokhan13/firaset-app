import 'dart:convert';
import 'dart:io';

import 'package:firaset/motor/icerik_yukleyici.dart';
import 'package:firaset/motor/karne_motoru.dart';
import 'package:firaset/olcum/oran_hesaplayici.dart' show hesapla;
import 'package:flutter_test/flutter_test.dart';

import '../support/fikstur_yukle.dart';

/// Golden üretmek için:  UPDATE_GOLDEN=1 flutter test
const _fiksturler = ['yuz_dengeli', 'yuz_uzun', 'yuz_genis_agiz'];

void main() {
  final icerik = aktifMeshUygulamalariniDosyadanYukle();
  const kod = JsonEncoder.withIndent('  ');

  for (final ad in _fiksturler) {
    test('karne golden eşleşir: $ad', () {
      final karne = uret(hesapla(fiksturuYukle(ad)), icerik);
      final uretilen = kod.convert(karne.toJson());
      final golden = File('test/golden/karne_$ad.golden.json');

      if (Platform.environment['UPDATE_GOLDEN'] == '1') {
        golden.parent.createSync(recursive: true);
        golden.writeAsStringSync('$uretilen\n');
      }

      expect(golden.existsSync(), isTrue, reason: 'UPDATE_GOLDEN=1 ile üret.');
      expect(uretilen, golden.readAsStringSync().trimRight());
    });
  }

  test('determinizm: aynı vektör iki kez → bit-bit aynı karne', () {
    final v = hesapla(fiksturuYukle('yuz_dengeli'));
    expect(
      jsonEncode(uret(v, icerik).toJson()),
      jsonEncode(uret(v, icerik).toJson()),
    );
  });
}
