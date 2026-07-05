import 'dart:math' as math;

import '../olcum/olcum_girdisi.dart';
import '../olcum/oran_hesaplayici.dart' show kIcerikSurumu, metrikGuven;
import 'bulanik_uyelik.dart';
import 'esikler_gecici.dart';
import 'karne.dart';
import 'kural_yapisi.dart';

/// Bir kuralın karneye girmesi için gereken en küçük aktivasyon.
const double kAktivasyonEsigi = 0.15;

/// |net|/toplam bunun altındaysa kişi itidale (dengeye) yorulur (`yontem.itidal_ilkesi`).
const double kDengeEsigi = 0.34;

/// Orta-üyelik ortalaması bunun üstündeyse BB-89 itidal bonusu eklenir.
const double kItidalBonusEsigi = 0.6;

/// Oran vektöründen deterministik karne üretir (saf; Date/random/LLM yok).
///
/// [aktifKuralMetinleri]: `icerik_yukleyici.aktifMeshUygulamalari` çıktısı
/// (id → uygulama). Kullanıcıya giden metin YALNIZ buradan gelir (düzeltme a).
Karne uret(OranVektoru vektor, Map<String, String> aktifKuralMetinleri) {
  // 1) Bulanık üyelikler.
  final uyelikler = <String, DilimUyeligi>{};
  for (final e in vektor.oranlar.entries) {
    final esik = kGeciciEsikler[e.key];
    if (esik != null) uyelikler[e.key] = uyelik(e.value.deger, esik);
  }

  double uyelikDeger(Kosul k) => uyelikler[k.metrik]?[k.dilim] ?? 0.0;
  bool bMetrikMi(String m) => metrikGuven[m] == Guven.b;

  final yorumlar = <BolgeYorumu>[];
  final eksikler = <IcerikEksigi>[];
  double olumlu = 0, olumsuz = 0;

  // 2) Kural eşleme + aktivasyon.
  kKuralYapisi.forEach((id, yapi) {
    if (!aktifKuralMetinleri.containsKey(id)) {
      return; // durum kapısı / yüklenmemiş
    }

    Tetikleyici? enIyi;
    double enIyiAkt = 0;
    for (final t in yapi.tetikleyiciler) {
      if (t.gosterme) continue; // (GÖSTERME) atla
      final ham = t.kosullar.map(uyelikDeger).reduce(math.min); // AND = min
      final agirlik = t.kosullar.any((k) => bMetrikMi(k.metrik))
          ? kBAgirlik
          : 1.0;
      final etkin = ham * agirlik; // güven-B düşük ağırlık (D-017)
      if (etkin > enIyiAkt) {
        enIyiAkt = etkin;
        enIyi = t;
      }
    }
    if (enIyi == null || enIyiAkt < kAktivasyonEsigi) return;

    // Düzeltme a: uygulama metni bu değeri kapsamıyorsa ham metne DÜŞME, atla + raporla.
    if (!enIyi.uygulamadaVar) {
      eksikler.add(
        IcerikEksigi(
          kuralId: id,
          deger: enIyi.eslemeAnahtari ?? '',
          neden: 'aktive oldu ama uygulama metninde karşılığı yok',
        ),
      );
      return;
    }

    final guven = enIyi.kosullar.any((k) => bMetrikMi(k.metrik)) ? 'B' : 'A';
    yorumlar.add(
      BolgeYorumu(
        bolge: yapi.bolge,
        kuralId: id,
        metin: aktifKuralMetinleri[id]!, // YALNIZ uygulama alanı
        yon: enIyi.yon,
        guven: guven,
        aktivasyon: _yuvarla(enIyiAkt),
      ),
    );
    if (enIyi.yon == Yon.olumlu) {
      olumlu += enIyiAkt;
    } else if (enIyi.yon == Yon.olumsuz) {
      olumsuz += enIyiAkt;
    }
  });

  // 3) İtidal: zıt deliller dengelenir, çoğunluk tarafı bilinir.
  final toplam = olumlu + olumsuz;
  final net = olumlu - olumsuz;
  final dengeMi = toplam < 1e-9 || (net.abs() / toplam) < kDengeEsigi;

  // 4) BB-89: metriklerin orta-üyelik ortalaması → itidal skoru.
  final skor = uyelikler.isEmpty
      ? 0.0
      : uyelikler.values.map((u) => u.orta).reduce((a, b) => a + b) /
            uyelikler.length;
  final bonus = (skor >= kItidalBonusEsigi)
      ? aktifKuralMetinleri['BB-89']
      : null;

  // Deterministik sıralama.
  yorumlar.sort((a, b) {
    final c = a.bolge.compareTo(b.bolge);
    return c != 0 ? c : a.kuralId.compareTo(b.kuralId);
  });
  eksikler.sort((a, b) => a.kuralId.compareTo(b.kuralId));

  return Karne(
    surum: kIcerikSurumu,
    esikSurumu: kEsikSurumu,
    kalibrasyon: 'gecici',
    yorumlar: yorumlar,
    itidal: ItidalSkoru(
      skor: _yuvarla(skor),
      olumluAgirlik: _yuvarla(olumlu),
      olumsuzAgirlik: _yuvarla(olumsuz),
      net: _yuvarla(net),
      dengeMi: dengeMi,
      bonusMetin: bonus,
    ),
    eksikler: eksikler,
  );
}

double _yuvarla(double v) => (v * 1e6).round() / 1e6;
