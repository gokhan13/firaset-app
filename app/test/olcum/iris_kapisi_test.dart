import 'package:firaset/olcum/landmark_motoru.dart';
import 'package:firaset/olcum/oran_hesaplayici.dart';
import 'package:firaset/olcum/olcum_girdisi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('478 landmark altı (iris yok) → hesapla reddeder', () {
    final az = OlcumGirdisi(
      noktalar: List<Landmark>.generate(
        400,
        (_) => const Landmark(0.5, 0.5, 0),
      ),
      enPiksel: 1000,
      boyPiksel: 1000,
    );
    expect(() => hesapla(az), throwsArgumentError);
  });
}
