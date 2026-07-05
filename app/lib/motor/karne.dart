import 'dart:collection';

import 'kural_yapisi.dart' show Yon;

/// Bir bölge için tek karne maddesi. [metin] YALNIZ kuralın `uygulama` alanından
/// gelir (editör onaylı yumuşatılmış metin); ham `ozellikler`/`esleme` asla.
class BolgeYorumu {
  const BolgeYorumu({
    required this.bolge,
    required this.kuralId,
    required this.metin,
    required this.yon,
    required this.guven,
    required this.aktivasyon,
  });

  final String bolge;
  final String kuralId;
  final String metin;
  final Yon yon;
  final String guven; // 'A' | 'B'
  final double aktivasyon;

  Map<String, dynamic> toJson() => {
    'bolge': bolge,
    'kuralId': kuralId,
    'metin': metin,
    'yon': yon.name,
    'guven': guven,
    'aktivasyon': aktivasyon,
  };
}

/// İtidal (denge) değerlendirmesi + BB-89 skoru.
class ItidalSkoru {
  const ItidalSkoru({
    required this.skor,
    required this.olumluAgirlik,
    required this.olumsuzAgirlik,
    required this.net,
    required this.dengeMi,
    this.bonusMetin,
  });

  /// BB-89: metriklerin orta-üyelik ortalaması (0..1).
  final double skor;
  final double olumluAgirlik;
  final double olumsuzAgirlik;
  final double net;
  final bool dengeMi;

  /// Yüksek itidalde BB-89 `uygulama` metni; aksi halde null.
  final String? bonusMetin;

  Map<String, dynamic> toJson() => {
    'skor': skor,
    'olumluAgirlik': olumluAgirlik,
    'olumsuzAgirlik': olumsuzAgirlik,
    'net': net,
    'dengeMi': dengeMi,
    'bonusMetin': bonusMetin,
  };
}

/// Aktive olan ama `uygulama` metninde karşılığı olmayan eşleme değeri:
/// karneden atlanır, içerik düzeltmesi için raporlanır (ham metne düşülmez).
class IcerikEksigi {
  const IcerikEksigi({
    required this.kuralId,
    required this.deger,
    required this.neden,
  });

  final String kuralId;
  final String deger;
  final String neden;

  Map<String, dynamic> toJson() => {
    'kuralId': kuralId,
    'deger': deger,
    'neden': neden,
  };
}

/// Tarihsel mercek karnesi. Deterministik (aynı vektör → aynı karne, Altın Kural 3).
/// [kalibrasyon]='gecici' → hiçbir çıktı kalibre sanılmasın (D-018).
class Karne {
  const Karne({
    required this.surum,
    required this.esikSurumu,
    required this.kalibrasyon,
    required this.yorumlar,
    required this.itidal,
    required this.eksikler,
  });

  final String surum; // 'content/v1'
  final String esikSurumu;
  final String kalibrasyon; // 'gecici'
  final List<BolgeYorumu> yorumlar;
  final ItidalSkoru itidal;
  final List<IcerikEksigi> eksikler;

  /// Deterministik JSON (üst anahtarlar sıralı; listeler motorda sıralanmış gelir).
  Map<String, dynamic> toJson() {
    final m = SplayTreeMap<String, dynamic>();
    m['surum'] = surum;
    m['esikSurumu'] = esikSurumu;
    m['kalibrasyon'] = kalibrasyon;
    m['itidal'] = itidal.toJson();
    m['yorumlar'] = yorumlar.map((y) => y.toJson()).toList();
    m['eksikler'] = eksikler.map((e) => e.toJson()).toList();
    return m;
  }
}
