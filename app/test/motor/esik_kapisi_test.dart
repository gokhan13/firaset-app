import 'package:firaset/motor/esikler_gecici.dart';
import 'package:firaset/motor/icerik_yukleyici.dart';
import 'package:firaset/motor/karne_motoru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/motor_yardim.dart';

/// Geçici sabitleri TEK yerden bekçiler: kimse yanlışlıkla "kalibre" sanmasın.
void main() {
  test('eşikler kalibre edilmemiş, B-ağırlığı düşük', () {
    expect(kEsiklerKalibreEdildi, isFalse);
    expect(kEsikSurumu, 'gecici-1');
    expect(kBAgirlik, 0.3);
    expect(kBant, 0.15);
  });

  test('karne çıktısı kendini "gecici" etiketler', () {
    final k = uret(vektorYap(), aktifMeshUygulamalariniDosyadanYukle());
    expect(k.kalibrasyon, 'gecici');
    expect(k.esikSurumu, 'gecici-1');
  });
}
