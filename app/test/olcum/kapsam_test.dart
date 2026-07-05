import 'dart:convert';
import 'dart:io';

import 'package:firaset/olcum/oran_hesaplayici.dart';
import 'package:flutter_test/flutter_test.dart';

/// content/v1/01 ile oran hesaplayıcının birebir eşleşme güvencesi:
/// her aktif `kanal=kamera_mesh` kuralı ya bir metrikle kapsanır ya da belgeli
/// istisnadır. İçerik yeni mesh kuralı eklerse bu test kırılır (drift kapısı).
void main() {
  test('aktif kamera_mesh kuralları birebir kapsanır', () {
    final icerik =
        jsonDecode(
              File(
                '../content/v1/01_kiyafetname_kurallari.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final kurallar = <dynamic>[
      ...icerik['kurallar_bas_boyun'] as List,
      ...icerik['kurallar_diger_uzuvlar'] as List,
    ];
    final aktifMesh = kurallar
        .where((r) => r['kanal'] == 'kamera_mesh' && r['durum'] == null)
        .map((r) => r['id'] as String)
        .toSet();

    final kapsanan = {...kapsananKurallar, ...belgeliIstisnalar.keys};

    // Her aktif mesh kuralı kapsanmalı.
    expect(
      aktifMesh.difference(kapsanan),
      isEmpty,
      reason: 'Kapsanmayan aktif mesh kuralları',
    );
    // Hesaplayıcı içerikte olmayan bir kural id'sine atıfta bulunmamalı.
    expect(
      kapsananKurallar.difference(aktifMesh),
      isEmpty,
      reason: 'İçerikte bulunmayan kural id referansı',
    );
  });
}
