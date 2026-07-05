import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CLAUDE.md Altin Kural 1 regresyon kapisi: lib/ altinda fotograf-diske-yazma
/// veya kalici depolama API cagrisi bulunmamali. Yalniz bellek-ici kamera
/// akisi islenir. (Yorumlarda API adi gecmesi diye cagri deseni "isim(" aranir.)
void main() {
  test('lib/ altinda foto/diske-yazma API cagrisi yok', () {
    const yasakDesenler = <String>[
      'takePicture(',
      'writeToFile(',
      'writeAsBytes',
      'getTemporaryDirectory(',
      'getApplicationDocumentsDirectory(',
      'package:path_provider',
    ];

    final ihlaller = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Uretilmis yerellestirme dosyalarini atla.
      if (entity.path.contains('app_localizations')) continue;
      final icerik = entity.readAsStringSync();
      for (final desen in yasakDesenler) {
        if (icerik.contains(desen)) {
          ihlaller.add('${entity.path}: $desen');
        }
      }
    }

    expect(
      ihlaller,
      isEmpty,
      reason: 'Altin Kural 1 ihlali (goruntu diske yazilamaz): $ihlaller',
    );
  });
}
