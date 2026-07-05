import 'package:firaset/motor/esikler_gecici.dart';
import 'package:firaset/olcum/olcum_girdisi.dart';
import 'package:firaset/olcum/oran_hesaplayici.dart'
    show kIcerikSurumu, metrikGuven;

/// Tüm metrikleri orta merkeze koyan bir oran vektörü; [override] ile bazılarını kaydır.
OranVektoru vektorYap([Map<String, double> override = const {}]) {
  final oranlar = <String, MetrikOran>{};
  kGeciciEsikler.forEach((m, e) {
    oranlar[m] = MetrikOran(override[m] ?? e.merkez, metrikGuven[m]!);
  });
  return OranVektoru(
    surum: kIcerikSurumu,
    hesaplayiciSurum: 1,
    oranlar: oranlar,
  );
}

/// Bir metriği tam alt dilime düşüren değer (merkez × (1 − 2·bant)).
double altDeger(String metrik) {
  final e = kGeciciEsikler[metrik]!;
  return e.merkez * (1 - 2 * e.bant);
}

/// Bir metriği tam üst dilime çıkaran değer (merkez × (1 + 2·bant)).
double ustDeger(String metrik) {
  final e = kGeciciEsikler[metrik]!;
  return e.merkez * (1 + 2 * e.bant);
}
