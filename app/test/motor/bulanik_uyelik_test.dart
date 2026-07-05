import 'package:firaset/motor/bulanik_uyelik.dart';
import 'package:firaset/motor/esikler_gecici.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const e = EsikBandi(1.0); // merkez 1, bant 0.15 → yarı-bant 0.15

  test('merkezde orta=1, uçlar 0', () {
    final u = uyelik(1.0, e);
    expect(u.orta, 1.0);
    expect(u.alt, 0.0);
    expect(u.ust, 0.0);
  });

  test('bant kenarında (norm=1) hâlâ orta baskın', () {
    final u = uyelik(1.15, e);
    expect(u.orta, closeTo(1.0, 1e-9));
    expect(u.ust, closeTo(0.0, 1e-9));
  });

  test('üst uçta (norm=2) ust=1, orta=0', () {
    final u = uyelik(1.30, e);
    expect(u.ust, closeTo(1.0, 1e-9));
    expect(u.orta, closeTo(0.0, 1e-9));
  });

  test('alt uçta (norm=-2) alt=1, orta=0', () {
    final u = uyelik(0.70, e);
    expect(u.alt, closeTo(1.0, 1e-9));
    expect(u.orta, closeTo(0.0, 1e-9));
  });

  test('geçiş bölgesinde (norm=-1.5) alt+orta≈1', () {
    final u = uyelik(0.775, e);
    expect(u.alt + u.orta, closeTo(1.0, 1e-9));
    expect(u.alt, closeTo(0.5, 1e-9));
  });

  test('üst dilim orana göre monoton artar', () {
    expect(uyelik(1.20, e).ust, lessThan(uyelik(1.28, e).ust));
  });
}
