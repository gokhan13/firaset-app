import 'dart:async';

import 'package:firaset/olcum/landmark_motoru.dart';

/// Testler icin sahte [LandmarkMotoru]. Kamera/native gerektirmez; sonuclari
/// [yay] ile elle tetikler. UI ve olcum testleri yalniz arayuze baglidir (koruma #2).
class FakeLandmarkMotoru implements LandmarkMotoru {
  final StreamController<LandmarkSonucu> _c =
      StreamController<LandmarkSonucu>.broadcast();

  bool basladi = false;
  final List<KameraKaresi> verilenKareler = <KameraKaresi>[];

  @override
  Future<void> baslat() async => basladi = true;

  @override
  void kareVer(KameraKaresi kare) => verilenKareler.add(kare);

  @override
  Stream<LandmarkSonucu> get sonuclar => _c.stream;

  @override
  Future<void> durdur() async {
    if (!_c.isClosed) await _c.close();
  }

  /// Test icinde bir sonuc yayinlar.
  void yay(LandmarkSonucu sonuc) => _c.add(sonuc);
}
