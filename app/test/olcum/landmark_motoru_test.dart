import 'dart:typed_data';

import 'package:firaset/olcum/landmark_motoru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_landmark_motoru.dart';

void main() {
  group('LandmarkSonucu', () {
    test('bos sonuc: 0 nokta, yuz yok', () {
      const sonuc = LandmarkSonucu.bos();
      expect(sonuc.noktaSayisi, 0);
      expect(sonuc.yuzVar, isFalse);
    });

    test('478 nokta -> noktaSayisi 478', () {
      final noktalar = List<Landmark>.generate(
        478,
        (i) => Landmark(i / 478, i / 478, 0),
      );
      final sonuc = LandmarkSonucu(noktalar: noktalar, yuzVar: true);
      expect(sonuc.noktaSayisi, 478);
      expect(sonuc.yuzVar, isTrue);
    });
  });

  group('LandmarkMotoru arayuz sozlesmesi (sahte impl)', () {
    test('kareVer -> sonuclar akisi sonucu yayar', () async {
      final motor = FakeLandmarkMotoru();
      await motor.baslat();
      expect(motor.basladi, isTrue);

      final beklenen = expectLater(
        motor.sonuclar,
        emits(
          predicate<LandmarkSonucu>((s) => s.noktaSayisi == 478 && s.yuzVar),
        ),
      );

      motor.kareVer(
        KameraKaresi(
          bytes: Uint8List(4),
          width: 1,
          height: 1,
          format: KareFormati.bgra,
          bytesPerRow: 4,
        ),
      );
      expect(motor.verilenKareler, hasLength(1));

      motor.yay(
        LandmarkSonucu(
          noktalar: List<Landmark>.generate(
            478,
            (i) => const Landmark(0, 0, 0),
          ),
          yuzVar: true,
        ),
      );

      await beklenen;
      await motor.durdur();
    });
  });
}
