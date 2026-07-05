import 'dart:typed_data';

/// Ham kamera karesinin piksel formati (paket-bagimsiz).
/// BGRA: iOS `startImageStream`; NV21: Android.
enum KareFormati { bgra, nv21 }

/// Tek bir 3B yuz noktasi. [x]/[y] normalize (0..1), [z] canonical derinlik.
class Landmark {
  const Landmark(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

/// Bir karenin landmark ciktisi: noktalar + yuz bulundu mu.
class LandmarkSonucu {
  const LandmarkSonucu({required this.noktalar, required this.yuzVar});

  /// Yuz bulunamadiginda kullanilan bos sonuc.
  const LandmarkSonucu.bos() : noktalar = const <Landmark>[], yuzVar = false;

  final List<Landmark> noktalar;
  final bool yuzVar;

  int get noktaSayisi => noktalar.length;
}

/// Paket-bagimsiz kamera karesi. Olcum katmani YALNIZ bunu bilir; ne `camera`
/// ne de `mediapipe_face_mesh` tipleri buraya sizar.
class KameraKaresi {
  const KameraKaresi({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
    required this.bytesPerRow,
    this.rotation = 0,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final KareFormati format;

  /// Satir basina bayt (stride).
  final int bytesPerRow;

  /// Sensor yonelimi (derece). Algilama icin gereklidir.
  final int rotation;
}

/// Yuz landmark motoru arayuzu.
///
/// Olcum modulu, UI ve testler YALNIZ bu arayuze baglidir. Somut motor
/// (`mediapipe_face_mesh`) yalnizca [MediapipeLandmarkMotoru] icinde gorunur;
/// baska bir motora (or. native federated plugin) gecis = tek implementasyon
/// dosyasi degisimi. Gerekce: docs/kararlar.md D-016.
abstract interface class LandmarkMotoru {
  /// Modelleri yukler ve motoru hazirlar. [kareVer]'den once cagrilmalidir.
  Future<void> baslat();

  /// Bellek-ici bir kareyi isler; sonucu [sonuclar] akisina yayar.
  /// Kare diske YAZILMAZ (CLAUDE.md Altin Kural 1).
  void kareVer(KameraKaresi kare);

  /// Kare basina landmark sonuclari.
  Stream<LandmarkSonucu> get sonuclar;

  /// Kaynaklari serbest birakir.
  Future<void> durdur();
}
