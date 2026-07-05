// =============================================================================
// GEÇİCİ EŞİKLER — KALİBRE EDİLMEMİŞTİR.
//
// Merkezler, Görev 3 `yuz_dengeli` fikstürünün oran değerlerinden türetildi:
// "kanonik yüz = normal" varsayımı (docs/kararlar.md D-018). Bu bir POPÜLASYON
// NORMU DEĞİLDİR; yalnız tutarlı, deterministik dilimleme sağlar. Faz 1
// persentilleri gelince bu dosya `esikler_v1` olur, [kEsiklerKalibreEdildi]
// true döner ve golden yeniden üretilir. Motor mantığı değişmez.
//
// TÜM geçici sabitler (eşikler + B-ağırlığı + bant + bayrak) burada yaşar;
// `esik_kapisi_test` tek yerden bekçiler.
// =============================================================================

/// Eşiklerin kalibre edilip edilmediği. Kalibrasyon gelene dek false.
const bool kEsiklerKalibreEdildi = false;

/// Geçici eşik seti sürümü (karneye yazılır).
const String kEsikSurumu = 'gecici-1';

/// Güven-B metriklerin karne ağırlığı. Kalibrasyona dek düşük (D-017). GEÇİCİ.
const double kBAgirlik = 0.3;

/// Orta dilimin merkeze göre oransal yarı-bant genişliği. GEÇİCİ.
const double kBant = 0.15;

/// Bir metriğin orta dilim merkezi ve bandı.
class EsikBandi {
  const EsikBandi(this.merkez, {this.bant = kBant});

  final double merkez;
  final double bant;
}

/// Metrik → geçici orta merkez (yuz_dengeli çapası). GEÇİCİ.
const Map<String, EsikBandi> kGeciciEsikler = {
  'agiz_genislik_orani': EsikBandi(0.857143),
  'alin_genislik_orani': EsikBandi(1.571429),
  'burun_genislik_orani': EsikBandi(0.5),
  'burun_kemer_derecesi': EsikBandi(0.053571),
  'burun_uc_dusuklugu': EsikBandi(0.392857),
  'burun_uc_yuvarlaklik': EsikBandi(0.714286),
  'burun_uzunluk_orani': EsikBandi(0.785714),
  'cene_genislik_orani': EsikBandi(1.714286),
  'dudak_kalinlik_orani': EsikBandi(0.321429),
  'goz_aciklik_orani': EsikBandi(0.415227),
  'goz_boyut_orani': EsikBandi(0.430057),
  'goz_derinlik_z': EsikBandi(0.178571),
  'kas_araligi_orani': EsikBandi(0.571429),
  'kas_kalinlik_orani': EsikBandi(0.142857),
  'kas_kavis_derecesi': EsikBandi(2.651635),
  'kas_uc_incelik': EsikBandi(0.559017),
  'kas_uzunluk_orani': EsikBandi(0.571429),
  'yuz_dolgunluk_orani': EsikBandi(1.428571),
  'yuz_kontur_z': EsikBandi(0.428571),
  'yuz_uzunluk_orani': EsikBandi(1.25),
};
