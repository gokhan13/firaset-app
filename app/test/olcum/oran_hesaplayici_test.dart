import 'package:firaset/olcum/landmark_motoru.dart';
import 'package:firaset/olcum/oran_hesaplayici.dart';
import 'package:firaset/olcum/olcum_girdisi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fikstur_yukle.dart';

OlcumGirdisi _donustur(OlcumGirdisi g, {double olcek = 1, double kaydir = 0}) {
  final yeni = g.noktalar
      .map(
        (l) =>
            Landmark(l.x * olcek + kaydir, l.y * olcek + kaydir, l.z * olcek),
      )
      .toList();
  return OlcumGirdisi(
    noktalar: yeni,
    enPiksel: g.enPiksel,
    boyPiksel: g.boyPiksel,
  );
}

void main() {
  final dengeli = fiksturuYukle('yuz_dengeli');

  test('20 metrik üretir ve güven etiketleri metrikGuven ile tutarlı', () {
    final v = hesapla(dengeli);
    expect(v.oranlar.keys.toSet(), metrikGuven.keys.toSet());
    for (final e in v.oranlar.entries) {
      expect(e.value.guven, metrikGuven[e.key], reason: e.key);
    }
    expect(v.surum, 'content/v1');
    expect(v.hesaplayiciSurum, kHesaplayiciSurum);
  });

  test('bilinen geometri → beklenen oran (fikstür koordinatlarından)', () {
    final o = hesapla(dengeli).oranlar;
    // yüz yüksekliği 800px / genişliği 640px = 1.25
    expect(o['yuz_uzunluk_orani']!.deger, closeTo(1.25, 1e-5));
    // ağız genişliği 240px / IPD 280px ≈ 0.857143
    expect(o['agiz_genislik_orani']!.deger, closeTo(0.857143, 1e-5));
  });

  test('ölçek değişmezliği (uniform 3B ölçek → aynı vektör)', () {
    final a = hesapla(dengeli).oranlar;
    final b = hesapla(_donustur(dengeli, olcek: 0.5)).oranlar;
    for (final k in a.keys) {
      expect(b[k]!.deger, closeTo(a[k]!.deger, 1e-6), reason: k);
    }
  });

  test('öteleme değişmezliği (x/y kaydır → aynı vektör)', () {
    final a = hesapla(dengeli).oranlar;
    final b = hesapla(_donustur(dengeli, kaydir: 0.1)).oranlar;
    for (final k in a.keys) {
      expect(b[k]!.deger, closeTo(a[k]!.deger, 1e-6), reason: k);
    }
  });

  test('davranış: uzun yüz → yuz_uzunluk_orani artar', () {
    final d = hesapla(dengeli).oranlar['yuz_uzunluk_orani']!.deger;
    final u = hesapla(
      fiksturuYukle('yuz_uzun'),
    ).oranlar['yuz_uzunluk_orani']!.deger;
    expect(u, greaterThan(d));
  });

  test('davranış: geniş ağız → agiz_genislik_orani artar', () {
    final d = hesapla(dengeli).oranlar['agiz_genislik_orani']!.deger;
    final g = hesapla(
      fiksturuYukle('yuz_genis_agiz'),
    ).oranlar['agiz_genislik_orani']!.deger;
    expect(g, greaterThan(d));
  });
}
