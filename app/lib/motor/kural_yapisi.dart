import 'bulanik_uyelik.dart';

/// Kuralın karnedeki genel işareti.
enum Yon { olumlu, olumsuz, karisik, notr }

/// Tek koşul: bir metriğin belirli dilimde olması.
class Kosul {
  const Kosul(this.metrik, this.dilim);
  final String metrik;
  final Dilim dilim;
}

/// Bir kuralı aktive eden tetikleyici. [kosullar] AND'lenir (aktivasyon = min üyelik).
class Tetikleyici {
  const Tetikleyici({
    required this.kosullar,
    required this.yon,
    this.eslemeAnahtari,
    this.uygulamadaVar = true,
    this.gosterme = false,
  });

  final List<Kosul> kosullar;
  final Yon yon;

  /// İlgili `esleme` değeri (raporlama / içerik-eksiği için); ozellikler kuralı ise null.
  final String? eslemeAnahtari;

  /// Kuralın `uygulama` metni bu değeri kapsıyor mu (editöryel). false → karneden
  /// atlanır ve "içerik eksiği" olarak raporlanır (ham ozellikler'e düşülmez).
  final bool uygulamadaVar;

  /// İçerikte `(GÖSTERME)` etiketli değer → tamamen atlanır (içerik sözleşmesi).
  final bool gosterme;
}

/// Bir kuralın bölgesi ve tetikleyicileri.
class KuralYapisi {
  const KuralYapisi(this.bolge, this.tetikleyiciler);
  final String bolge;
  final List<Tetikleyici> tetikleyiciler;
}

const _alt = Dilim.alt;
const _orta = Dilim.orta;
const _ust = Dilim.ust;

/// KOD tarafı yapı: her aktif `kamera_mesh` kural id'si → hangi metrik+dilim
/// onu aktive eder. Sözcükler (uygulama metni) içerikten gelir; burada YALNIZ yapı.
/// BB-40b (ölçülemez) ve BB-89 (itidal, ayrı hesaplanır) burada yoktur.
const Map<String, KuralYapisi> kKuralYapisi = {
  // Alın (3'lü eksen).
  'BB-16': KuralYapisi('alın', [
    Tetikleyici(
      kosullar: [Kosul('alin_genislik_orani', _alt)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-18': KuralYapisi('alın', [
    Tetikleyici(
      kosullar: [Kosul('alin_genislik_orani', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-19': KuralYapisi('alın', [
    Tetikleyici(
      kosullar: [Kosul('alin_genislik_orani', _orta)],
      yon: Yon.olumlu,
    ),
  ]),

  // Kaş.
  'BB-25': KuralYapisi('kaş', [
    Tetikleyici(kosullar: [Kosul('kas_uc_incelik', _alt)], yon: Yon.olumsuz),
  ]),
  'BB-27': KuralYapisi('kaş', [
    Tetikleyici(
      kosullar: [Kosul('kas_araligi_orani', _ust)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'aralıklı/açık',
    ),
    Tetikleyici(
      kosullar: [Kosul('kas_araligi_orani', _alt)],
      yon: Yon.notr,
      eslemeAnahtari: 'bitişik/çatık',
      gosterme: true,
    ),
  ]),
  'BB-28': KuralYapisi('kaş', [
    // ince + uzun → kibir (birleşik).
    Tetikleyici(
      kosullar: [
        Kosul('kas_kalinlik_orani', _alt),
        Kosul('kas_uzunluk_orani', _ust),
      ],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'ince ve uzun',
    ),
    // sadece ince → güzel.
    Tetikleyici(
      kosullar: [
        Kosul('kas_kalinlik_orani', _alt),
        Kosul('kas_uzunluk_orani', _orta),
      ],
      yon: Yon.olumlu,
      eslemeAnahtari: 'ince',
    ),
  ]),
  // Kavisli = küçük apeks açısı = alt dilim.
  'BB-29': KuralYapisi('kaş', [
    Tetikleyici(kosullar: [Kosul('kas_kavis_derecesi', _alt)], yon: Yon.olumlu),
  ]),

  // Göz.
  'BB-30': KuralYapisi('göz', [
    Tetikleyici(
      kosullar: [Kosul('goz_boyut_orani', _alt), Kosul('goz_derinlik_z', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-33': KuralYapisi('göz', [
    Tetikleyici(
      kosullar: [Kosul('goz_boyut_orani', _alt)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'küçük',
    ),
    Tetikleyici(
      kosullar: [Kosul('goz_boyut_orani', _ust)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'büyük',
    ),
  ]),
  'BB-34': KuralYapisi('göz', [
    // patlak → uygulama metninde karşılığı yok (yalnız "orta" anlatılır) → içerik eksiği.
    Tetikleyici(
      kosullar: [Kosul('goz_derinlik_z', _ust)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'patlak/yumru',
      uygulamadaVar: false,
    ),
    Tetikleyici(
      kosullar: [Kosul('goz_derinlik_z', _alt)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'orta',
    ),
  ]),
  'BB-35': KuralYapisi('göz', [
    // kısık → uygulama yalnız "süzgün" anlatır → içerik eksiği.
    Tetikleyici(
      kosullar: [Kosul('goz_aciklik_orani', _alt)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'kısık (kıpık)',
      uygulamadaVar: false,
    ),
    Tetikleyici(
      kosullar: [Kosul('goz_aciklik_orani', _orta)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'süzgün bakış',
    ),
  ]),

  // Yüz.
  'BB-41': KuralYapisi('yüz', [
    // yumru → uygulama yalnız "yassı/düz" anlatır → içerik eksiği.
    Tetikleyici(
      kosullar: [Kosul('yuz_kontur_z', _ust)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'yumru',
      uygulamadaVar: false,
    ),
    Tetikleyici(
      kosullar: [Kosul('yuz_kontur_z', _alt)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'yassı/düz',
    ),
  ]),
  'BB-42': KuralYapisi('yüz', [
    Tetikleyici(
      kosullar: [Kosul('yuz_dolgunluk_orani', _alt)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'zayıf/arık',
    ),
    Tetikleyici(
      kosullar: [Kosul('yuz_dolgunluk_orani', _ust)],
      yon: Yon.olumsuz,
      eslemeAnahtari: 'etli',
    ),
  ]),
  'BB-43': KuralYapisi('yüz', [
    Tetikleyici(kosullar: [Kosul('yuz_uzunluk_orani', _ust)], yon: Yon.olumsuz),
  ]),
  'BB-45': KuralYapisi('yüz', [
    Tetikleyici(kosullar: [Kosul('yuz_uzunluk_orani', _alt)], yon: Yon.olumlu),
  ]),

  // Burun.
  'BB-51': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_uzunluk_orani', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-52': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_uzunluk_orani', _alt)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-53': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_uc_yuvarlaklik', _ust)],
      yon: Yon.olumlu,
    ),
  ]),
  'BB-54': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_uc_dusuklugu', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-55': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_genislik_orani', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-58': KuralYapisi('burun', [
    Tetikleyici(
      kosullar: [Kosul('burun_kemer_derecesi', _ust)],
      yon: Yon.olumlu,
    ),
  ]),

  // Ağız.
  'BB-59': KuralYapisi('ağız', [
    Tetikleyici(
      kosullar: [Kosul('agiz_genislik_orani', _alt)],
      yon: Yon.karisik,
    ),
  ]),
  'BB-60': KuralYapisi('ağız', [
    Tetikleyici(
      kosullar: [Kosul('agiz_genislik_orani', _ust)],
      yon: Yon.olumlu,
      eslemeAnahtari: 'büyük',
    ),
    Tetikleyici(
      kosullar: [Kosul('agiz_genislik_orani', _ust)],
      yon: Yon.notr,
      eslemeAnahtari: 'eğri',
      gosterme: true,
    ),
  ]),

  // Dudak.
  'BB-70': KuralYapisi('dudak', [
    Tetikleyici(
      kosullar: [Kosul('dudak_kalinlik_orani', _alt)],
      yon: Yon.olumlu,
    ),
  ]),
  'BB-71': KuralYapisi('dudak', [
    Tetikleyici(
      kosullar: [Kosul('dudak_kalinlik_orani', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),

  // Çene (3'lü eksen).
  'BB-75': KuralYapisi('çene', [
    Tetikleyici(
      kosullar: [Kosul('cene_genislik_orani', _alt)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-76': KuralYapisi('çene', [
    Tetikleyici(
      kosullar: [Kosul('cene_genislik_orani', _ust)],
      yon: Yon.olumsuz,
    ),
  ]),
  'BB-77': KuralYapisi('çene', [
    Tetikleyici(
      kosullar: [Kosul('cene_genislik_orani', _orta)],
      yon: Yon.olumlu,
    ),
  ]),
};
