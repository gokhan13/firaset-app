import 'dart:convert';
import 'dart:io';

/// content/v1/01'den **aktif** (durum=onay_bekliyor) `kamera_mesh` kurallarının
/// `id → uygulama` metnini çıkarır. Motorun gördüğü TEK sözcük kaynağıdır;
/// ham `ozellikler`/`esleme` buraya girmez (kullanıcı karnesine asla).
Map<String, String> aktifMeshUygulamalari(String jsonMetni) {
  final d = jsonDecode(jsonMetni) as Map<String, dynamic>;
  final kurallar = <dynamic>[
    ...d['kurallar_bas_boyun'] as List,
    ...d['kurallar_diger_uzuvlar'] as List,
  ];
  final sonuc = <String, String>{};
  for (final r in kurallar) {
    if (r['kanal'] == 'kamera_mesh' && r['durum'] == null) {
      final uyg = r['uygulama'];
      if (uyg is String && uyg.isNotEmpty) {
        sonuc[r['id'] as String] = uyg;
      }
    }
  }
  return sonuc;
}

/// Depo dosyasından yükler (app/testler; cwd=app → ../content).
Map<String, String> aktifMeshUygulamalariniDosyadanYukle() =>
    aktifMeshUygulamalari(
      File('../content/v1/01_kiyafetname_kurallari.json').readAsStringSync(),
    );
