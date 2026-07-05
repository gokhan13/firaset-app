import 'dart:ui';

/// Görüntü (sensör) uzayı → gösterim uzayı dönüşümü — TEK tanım.
///
/// Hem ham önizleme dokusu (`buildPreview`) hem de [NoktaUstuBoyayici] AYNI
/// [ceyrekDonus] + [ayna] değerlerini kullanır; ayrıca cover kırpması ikisini
/// saran ortak `FittedBox` ile yapılır. Böylece noktalar dururken yüze oturur
/// (kayma varsa dönüşüm hatasıdır).
///
/// Not: landmark motoru (`mediapipe_face_mesh`, mirrorHorizontal:true) çıktı x'ini
/// önceden aynalar; [motorAynaladi] ile bu tek seferlik geri alınır (ham sensör
/// uzayına dönülür), sonra doku ile birebir aynı dönüşüm uygulanır. Bu yüzden
/// [ceyrekDonus]/[ayna] tamamen KOZMETİKtir (görüntüyü dik/aynalı yapar),
/// hizalamayı bozmaz.
class OnizlemeDonusumu {
  const OnizlemeDonusumu({
    required this.hamBoyut,
    required this.ceyrekDonus,
    required this.ayna,
    required this.motorAynaladi,
  });

  /// Sensör görüntü boyutu (`controller.value.previewSize`).
  final Size hamBoyut;

  /// Saat yönü çeyrek dönüş (0..3). Hem dokuya hem noktalara uygulanır.
  final int ceyrekDonus;

  /// Kozmetik yatay ayna (ön kamera selfie görünümü).
  final bool ayna;

  /// Motorun mirrorHorizontal:true ile x'i önceden aynalayıp aynalamadığı.
  final bool motorAynaladi;

  bool get _tekDonus => ceyrekDonus.isOdd;

  /// Rotasyon sonrası gösterim boyutu (tek çeyreklerde en/boy takas edilir).
  Size get gosterimBoyutu =>
      _tekDonus ? Size(hamBoyut.height, hamBoyut.width) : hamBoyut;

  /// Motor-normalize (0..1) landmark → gösterim uzayı pikseli.
  Offset noktaGosterime(double nx, double ny) {
    // 1) Motorun önceden uyguladığı aynayı geri al → ham sensör uzayı.
    double sx = motorAynaladi ? 1.0 - nx : nx;
    double sy = ny;

    // 2) Doku ile AYNI rotasyon.
    double x, y;
    switch (ceyrekDonus % 4) {
      case 0:
        x = sx;
        y = sy;
      case 1:
        x = 1.0 - sy;
        y = sx;
      case 2:
        x = 1.0 - sx;
        y = 1.0 - sy;
      default:
        x = sy;
        y = 1.0 - sx;
    }

    // 3) Doku ile AYNI kozmetik ayna.
    if (ayna) x = 1.0 - x;

    final g = gosterimBoyutu;
    return Offset(x * g.width, y * g.height);
  }
}
