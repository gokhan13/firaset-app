import 'package:firaset/kamera/kamera_denetleyici.dart';
import 'package:firaset/kamera/kamera_ekrani.dart';
import 'package:firaset/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_landmark_motoru.dart';

void main() {
  testWidgets('KameraEkrani sahte motorla cokmeden kurulur ve baslik gosterir', (
    tester,
  ) async {
    final fake = FakeLandmarkMotoru();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [landmarkMotoruProvider.overrideWith((ref) => fake)],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KameraEkrani(),
        ),
      ),
    );

    // Kamera eklentisi test ortaminda yok; ekran "yukleniyor" durumunda kalabilir
    // (CircularProgressIndicator sonsuz animasyon -> pumpAndSettle kullanilmaz).
    // Birkac kare pompalayip motorun baslatildigini ve ekranin coker olmadigini
    // dogrulariz.
    await tester.pump(); // initState + motor.baslat() microtask'i
    await tester.pump(const Duration(milliseconds: 50));

    // Baslik (pocTitle, tr) her durumda AppBar'da bulunur.
    expect(find.text('Yuz taramasi (POC)'), findsOneWidget);
    // Sahte motor (arayuz uzerinden) baslatilmis olmali.
    expect(fake.basladi, isTrue);
  });
}
