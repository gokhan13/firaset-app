import 'dart:convert';
import 'dart:io';

import 'package:firaset/motor/icerik_yukleyici.dart';
import 'package:firaset/motor/karne_metni.dart';
import 'package:firaset/motor/karne_motoru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/motor_yardim.dart';

/// Düzeltme a + Altın Kural 8: karne metinleri YALNIZ `uygulama` alanından gelir
/// (ham `ozellikler`/`esleme` sızmaz) ve yasak kalıp içermez.
void main() {
  final icerik = aktifMeshUygulamalariniDosyadanYukle();
  final raw =
      jsonDecode(
            File(
              '../content/v1/01_kiyafetname_kurallari.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final kurallar = <dynamic>[
    ...raw['kurallar_bas_boyun'] as List,
    ...raw['kurallar_diger_uzuvlar'] as List,
  ];
  final uygulamaSet = <String>{};
  final hamSet = <String>{};
  for (final r in kurallar) {
    final uyg = r['uygulama'];
    if (uyg is String) uygulamaSet.add(uyg);
    final oz = r['ozellikler'];
    if (oz is List) hamSet.addAll(oz.cast<String>());
    final es = r['esleme'];
    if (es is Map) hamSet.addAll(es.values.cast<String>());
  }

  // Birden çok kuralı aktive eden bir yüz.
  final karne = uret(
    vektorYap({
      'cene_genislik_orani': altDeger('cene_genislik_orani'),
      'alin_genislik_orani': ustDeger('alin_genislik_orani'),
      'burun_uzunluk_orani': ustDeger('burun_uzunluk_orani'),
    }),
    icerik,
  );

  test('yorumlar yalnız uygulama alanından; ham ozellikler/esleme sızmaz', () {
    expect(karne.yorumlar, isNotEmpty);
    for (final y in karne.yorumlar) {
      expect(
        uygulamaSet,
        contains(y.metin),
        reason: '${y.kuralId} metni uygulama değil',
      );
      expect(
        hamSet.contains(y.metin),
        isFalse,
        reason: '${y.kuralId} ham metin sızmış',
      );
    }
  });

  test('şablon metni disclaimer içerir ve yasak kalıp yok', () {
    final metin = karneMetni(
      karne,
      baslik: 'Kıyafetname böyle okur:',
      disclaimer: 'Eğlence ve kültür amaçlıdır.',
    );
    expect(metin, contains('Eğlence ve kültür amaçlıdır.'));
    for (final yasak in ['teşhis', 'kader', 'tıbbi']) {
      expect(metin.toLowerCase(), isNot(contains(yasak)), reason: yasak);
    }
  });
}
