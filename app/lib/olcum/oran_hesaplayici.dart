import 'dart:math' as math;

import 'landmark_indeksleri.dart';
import 'olcum_girdisi.dart';

/// Oran hesaplayıcı formül sürümü. Formül/metrik bilinçli değişince artırılır
/// (golden yeniden üretilir).
const int kHesaplayiciSurum = 1;

/// Bu hesaplayıcının ürettiği vektörün ait olduğu içerik sürümü.
const String kIcerikSurumu = 'content/v1';

/// Her metriğin beslediği `kanal=kamera_mesh` kural id'leri (birebir kapsama
/// belgesi). [kapsananKurallar] bundan türetilir; `kapsam_test` bunu content ile
/// karşılaştırır.
const Map<String, List<String>> metrikKurallari = {
  'yuz_uzunluk_orani': ['BB-43', 'BB-45'],
  'yuz_dolgunluk_orani': ['BB-42'],
  'yuz_kontur_z': ['BB-41'],
  'alin_genislik_orani': ['BB-16', 'BB-18', 'BB-19'],
  'kas_araligi_orani': ['BB-27'],
  'kas_kalinlik_orani': ['BB-28'],
  'kas_uzunluk_orani': ['BB-28'],
  'kas_kavis_derecesi': ['BB-29'],
  'kas_uc_incelik': ['BB-25'],
  'goz_boyut_orani': ['BB-33', 'BB-30'],
  'goz_aciklik_orani': ['BB-35', 'BB-34'],
  'goz_derinlik_z': ['BB-30', 'BB-34'],
  'burun_uzunluk_orani': ['BB-51', 'BB-52'],
  'burun_genislik_orani': ['BB-55'],
  'burun_uc_dusuklugu': ['BB-54'],
  'burun_uc_yuvarlaklik': ['BB-53'],
  'burun_kemer_derecesi': ['BB-58'],
  'agiz_genislik_orani': ['BB-59', 'BB-60'],
  'dudak_kalinlik_orani': ['BB-70', 'BB-71'],
  'cene_genislik_orani': ['BB-75', 'BB-76', 'BB-77'],
};

/// Metrik başına güven düzeyi (A: sağlam, B: z/profil bağımlı).
const Map<String, Guven> metrikGuven = {
  'yuz_uzunluk_orani': Guven.a,
  'yuz_dolgunluk_orani': Guven.a,
  'yuz_kontur_z': Guven.b,
  'alin_genislik_orani': Guven.a,
  'kas_araligi_orani': Guven.a,
  'kas_kalinlik_orani': Guven.a,
  'kas_uzunluk_orani': Guven.a,
  'kas_kavis_derecesi': Guven.a,
  'kas_uc_incelik': Guven.b,
  'goz_boyut_orani': Guven.a,
  'goz_aciklik_orani': Guven.a,
  'goz_derinlik_z': Guven.b,
  'burun_uzunluk_orani': Guven.a,
  'burun_genislik_orani': Guven.a,
  'burun_uc_dusuklugu': Guven.a,
  'burun_uc_yuvarlaklik': Guven.b,
  'burun_kemer_derecesi': Guven.b,
  'agiz_genislik_orani': Guven.a,
  'dudak_kalinlik_orani': Guven.a,
  'cene_genislik_orani': Guven.a,
};

/// Oran metrikleriyle kapsanan aktif `kamera_mesh` kural id'leri.
final Set<String> kapsananKurallar = {
  for (final kurallar in metrikKurallari.values) ...kurallar,
};

/// Bilinçli, belgeli kapsam istisnaları (metriğe eşlenmeyen aktif mesh kuralları).
/// - BB-40b: IPD normalizasyonu mutlak boyutu giderdiği için "küçük yüz" önden
///   ölçülemez; alternatif referans (saç/baş sınırı) yok. Faz 1'de saç/alın
///   segmentasyonuyla yeniden değerlendirilir.
/// - BB-89: İtidal (denge) skoru; ham oran değil, karne motorunda bu vektörden
///   türetilir.
const Map<String, String> belgeliIstisnalar = {
  'BB-40b':
      'IPD normalizasyonu boyutu giderir; alternatif referans yok (Faz 1).',
  'BB-89': 'İtidal skoru motorda vektörden türetilir; ham oran değil.',
};

/// Landmark listesinden deterministik oran vektörü üretir.
///
/// Saf fonksiyon (Date/random yok). < [Li.gerekliNoktaSayisi] nokta gelirse
/// (iris yoksa) [ArgumentError] atar.
OranVektoru hesapla(OlcumGirdisi girdi) {
  final n = girdi.noktalar;
  if (n.length < Li.gerekliNoktaSayisi) {
    throw ArgumentError(
      'Iris dahil ${Li.gerekliNoktaSayisi} landmark gerekli; alınan: ${n.length}',
    );
  }

  double px(int i) => n[i].x * girdi.enPiksel;
  double py(int i) => n[i].y * girdi.boyPiksel;
  double z(int i) => n[i].z;

  double uzaklik(int a, int b) {
    final dx = px(a) - px(b);
    final dy = py(a) - py(b);
    return math.sqrt(dx * dx + dy * dy);
  }

  double dikeyFark(int a, int b) => (py(a) - py(b)).abs();

  // Üç nokta arasındaki açı (radyan), tepe [b].
  double aci(int a, int b, int c) {
    final bax = px(a) - px(b), bay = py(a) - py(b);
    final bcx = px(c) - px(b), bcy = py(c) - py(b);
    final nokta = bax * bcx + bay * bcy;
    final len =
        math.sqrt(bax * bax + bay * bay) * math.sqrt(bcx * bcx + bcy * bcy);
    if (len == 0) return 0;
    return math.acos((nokta / len).clamp(-1.0, 1.0));
  }

  final ipd = uzaklik(Li.irisSagMerkez, Li.irisSolMerkez);
  if (ipd <= 0) {
    throw ArgumentError('IPD sıfır; geçersiz iris noktaları.');
  }

  final yuzYuksekligi = uzaklik(Li.alinUst, Li.ceneAlt);
  final yuzGenisligi = uzaklik(Li.yanakSag, Li.yanakSol);
  final gozGenisligiSag = uzaklik(Li.gozDisSag, Li.gozIcSag);

  // Ham (yuvarlanmamış) değerler.
  final ham = <String, double>{
    'yuz_uzunluk_orani': yuzYuksekligi / yuzGenisligi,
    'yuz_dolgunluk_orani': uzaklik(Li.ortaYanakSag, Li.ortaYanakSol) / ipd,
    'yuz_kontur_z':
        (z(Li.burunUcu) - (z(Li.yanakSag) + z(Li.yanakSol)) / 2).abs() *
        girdi.boyPiksel /
        ipd,
    'alin_genislik_orani': uzaklik(Li.sakakSag, Li.sakakSol) / ipd,
    'kas_araligi_orani': uzaklik(Li.kasIcSag, Li.kasIcSol) / ipd,
    'kas_kalinlik_orani': uzaklik(Li.kasTepeSag, Li.kasAltSag) / ipd,
    'kas_uzunluk_orani': uzaklik(Li.kasIcSag, Li.kasDisSag) / ipd,
    'kas_kavis_derecesi': aci(Li.kasIcSag, Li.kasTepeSag, Li.kasDisSag),
    'kas_uc_incelik':
        uzaklik(Li.kasDisSag, Li.kasDisAltSag) /
        uzaklik(Li.kasTepeSag, Li.kasAltSag),
    'goz_boyut_orani': gozGenisligiSag / ipd,
    'goz_aciklik_orani':
        uzaklik(Li.gozUstKapakSag, Li.gozAltKapakSag) / gozGenisligiSag,
    'goz_derinlik_z':
        (z(Li.gozIcSag) - z(Li.yanakSag)).abs() * girdi.boyPiksel / ipd,
    'burun_uzunluk_orani': uzaklik(Li.nasion, Li.subnasale) / ipd,
    'burun_genislik_orani': uzaklik(Li.alarSag, Li.alarSol) / ipd,
    'burun_uc_dusuklugu': dikeyFark(Li.ustDudakTepe, Li.burunUcu) / ipd,
    'burun_uc_yuvarlaklik':
        uzaklik(Li.burunDelikUstSag, Li.burunDelikUstSol) /
        uzaklik(Li.alarSag, Li.alarSol),
    'burun_kemer_derecesi':
        (z(Li.burunSirtOrta) - (z(Li.nasion) + z(Li.burunUcAlt)) / 2).abs() *
        girdi.boyPiksel /
        ipd,
    'agiz_genislik_orani': uzaklik(Li.agizKoseSag, Li.agizKoseSol) / ipd,
    'dudak_kalinlik_orani': uzaklik(Li.ustDudakTepe, Li.altDudakAlt) / ipd,
    'cene_genislik_orani': uzaklik(Li.ceneKoseSag, Li.ceneKoseSol) / ipd,
  };

  final oranlar = <String, MetrikOran>{
    for (final e in ham.entries)
      e.key: MetrikOran(_yuvarla(e.value), metrikGuven[e.key]!),
  };

  return OranVektoru(
    surum: kIcerikSurumu,
    hesaplayiciSurum: kHesaplayiciSurum,
    oranlar: oranlar,
  );
}

/// Determinizm için sabit 6 ondalık yuvarlama (golden bit-bit kararlı olsun).
double _yuvarla(double v) => (v * 1e6).round() / 1e6;
