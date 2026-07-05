import 'package:firaset/motor/icerik_yukleyici.dart';
import 'package:firaset/motor/kural_yapisi.dart';
import 'package:firaset/olcum/oran_hesaplayici.dart' show belgeliIstisnalar;
import 'package:flutter_test/flutter_test.dart';

/// Drift kapısı: içerikteki aktif kamera_mesh kuralları ile kod-tarafı yapı
/// (kKuralYapisi) birebir tutarlı olmalı.
void main() {
  final aktif = aktifMeshUygulamalariniDosyadanYukle().keys.toSet();

  test('her aktif mesh kuralı yapıda ya da belgeli istisnada', () {
    final kapsanan = {...kKuralYapisi.keys, ...belgeliIstisnalar.keys};
    expect(
      aktif.difference(kapsanan),
      isEmpty,
      reason: 'Yapıda olmayan aktif kural',
    );
  });

  test('yapıdaki her kural içerikte aktif (hayali id yok)', () {
    expect(
      kKuralYapisi.keys.toSet().difference(aktif),
      isEmpty,
      reason: 'İçerikte bulunmayan kural id',
    );
  });

  test('istisnalar yapıya girmemeli (BB-40b, BB-89)', () {
    expect(kKuralYapisi.containsKey('BB-40b'), isFalse);
    expect(kKuralYapisi.containsKey('BB-89'), isFalse);
  });

  test('birleşik kurallar iki koşulludur (BB-28, BB-30)', () {
    expect(kKuralYapisi['BB-28']!.tetikleyiciler.first.kosullar, hasLength(2));
    expect(kKuralYapisi['BB-30']!.tetikleyiciler.first.kosullar, hasLength(2));
  });
}
