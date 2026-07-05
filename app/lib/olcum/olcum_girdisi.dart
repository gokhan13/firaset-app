import 'dart:collection';

import 'landmark_motoru.dart';

/// Oran hesaplayıcının girdisi: bir karenin landmark'ları + görüntü boyutları.
///
/// Landmark x/y normalize (0..1); x genişliğe, y yüksekliğe göre. Oranların
/// doğru olması için izotropik piksel uzayına açmak gerekir, bu yüzden
/// [enPiksel]/[boyPiksel] gerekir. Ölçek IPD normalizasyonuyla giderilir.
class OlcumGirdisi {
  const OlcumGirdisi({
    required this.noktalar,
    required this.enPiksel,
    required this.boyPiksel,
  });

  final List<Landmark> noktalar;
  final int enPiksel;
  final int boyPiksel;
}

/// Bir metriğin güven düzeyi. A: önden mesh'ten sağlam; B: z/profil bağımlı,
/// düşük güven (eşikleri Faz 1 kalibrasyonu bekler — bkz. docs/kararlar.md D-017).
enum Guven {
  a,
  b;

  String get kod => this == Guven.a ? 'A' : 'B';
}

/// Tek bir metrik: değer + güven etiketi.
class MetrikOran {
  const MetrikOran(this.deger, this.guven);

  final double deger;
  final Guven guven;

  Map<String, dynamic> toJson() => {'deger': deger, 'guven': guven.kod};

  @override
  bool operator ==(Object other) =>
      other is MetrikOran && other.deger == deger && other.guven == guven;

  @override
  int get hashCode => Object.hash(deger, guven);
}

/// Soyut oran vektörü: sunucuya giden tek veri (fotoğraf değil — Altın Kural 1).
///
/// [surum] içerik sürümünü kaydeder (Altın Kural 7); [hesaplayiciSurum] formül
/// sürümü. Serileştirme deterministiktir: anahtarlar sıralı, değerler sabit
/// hassasiyete yuvarlıdır → aynı landmark → aynı vektör (Altın Kural 3).
class OranVektoru {
  const OranVektoru({
    required this.surum,
    required this.hesaplayiciSurum,
    required this.oranlar,
  });

  final String surum;
  final int hesaplayiciSurum;
  final Map<String, MetrikOran> oranlar;

  /// Deterministik JSON: `oranlar` anahtarları sıralı.
  Map<String, dynamic> toJson() {
    final sirali = SplayTreeMap<String, dynamic>();
    for (final e in oranlar.entries) {
      sirali[e.key] = e.value.toJson();
    }
    return {
      'surum': surum,
      'hesaplayiciSurum': hesaplayiciSurum,
      'oranlar': sirali,
    };
  }
}
