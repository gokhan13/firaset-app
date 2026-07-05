import 'package:firaset/motor/icerik_yukleyici.dart';
import 'package:firaset/motor/karne_motoru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/motor_yardim.dart';

void main() {
  final icerik = aktifMeshUygulamalariniDosyadanYukle();

  test('dengeli yüz: olumsuz yok, itidal skoru yüksek, BB-89 bonusu var', () {
    final k = uret(vektorYap(), icerik);
    expect(k.itidal.olumsuzAgirlik, 0.0);
    expect(k.itidal.olumluAgirlik, greaterThan(0));
    expect(k.itidal.skor, greaterThan(0.9));
    expect(k.itidal.bonusMetin, isNotNull);
    expect(k.kalibrasyon, 'gecici');
  });

  test(
    'tek olumsuz eksen: olumsuz ağırlık artar, net düşer, BB-89 skoru düşer',
    () {
      final temel = uret(vektorYap(), icerik).itidal;
      final ceneAlt = uret(
        vektorYap({'cene_genislik_orani': altDeger('cene_genislik_orani')}),
        icerik,
      ).itidal;
      expect(ceneAlt.olumsuzAgirlik, greaterThan(0));
      expect(ceneAlt.net, lessThan(temel.net));
      expect(ceneAlt.skor, lessThan(temel.skor));
    },
  );

  test(
    'zıt delil nötrler: olumlu eklemek net\'i geri yükseltir (yontem.itidal)',
    () {
      final ceneAlt = uret(
        vektorYap({'cene_genislik_orani': altDeger('cene_genislik_orani')}),
        icerik,
      ).itidal;
      final ceneAltDudakAlt = uret(
        vektorYap({
          'cene_genislik_orani': altDeger('cene_genislik_orani'),
          'dudak_kalinlik_orani': altDeger(
            'dudak_kalinlik_orani',
          ), // olumlu (ince)
        }),
        icerik,
      ).itidal;
      expect(ceneAltDudakAlt.net, greaterThan(ceneAlt.net));
    },
  );

  test('olumsuz çoğunluk: denge yok, net negatif', () {
    final k = uret(
      vektorYap({
        'cene_genislik_orani': altDeger('cene_genislik_orani'),
        'alin_genislik_orani': ustDeger('alin_genislik_orani'),
        'burun_uzunluk_orani': ustDeger('burun_uzunluk_orani'),
      }),
      icerik,
    ).itidal;
    expect(k.dengeMi, isFalse);
    expect(k.net, lessThan(0));
  });

  test(
    'içerik eksiği: kapsanmayan eşleme değeri karneye girmez, raporlanır',
    () {
      final k = uret(
        vektorYap({'goz_derinlik_z': ustDeger('goz_derinlik_z')}), // patlak
        icerik,
      );
      expect(k.eksikler.map((e) => e.kuralId), contains('BB-34'));
      expect(k.yorumlar.map((y) => y.kuralId), isNot(contains('BB-34')));
    },
  );
}
