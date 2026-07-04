# app/ - Flutter Uygulaması (henüz oluşturulmadı)
İlk Claude Code oturumunda sırayla:

**Görev 0 - Ortam:** `flutter doctor` çalıştır; Flutter SDK yoksa kur (stable kanal),
Android Studio/Xcode araç zincirlerini doğrula.

**Görev 1 - Proje:** Bu klasörde `flutter create . --project-name firaset --org com.DEGISTIR`
(org'u kurucunun ters-domain'iyle değiştir). Ardından: lint (analysis_options: flutter_lints),
Riverpod + intl/ARB iskeleti, `flutter analyze` temiz.

**Görev 2 - POC:** Kamera önizleme + MediaPipe Face Landmarker entegrasyonu; ekranda canlı
"478 nokta bulundu" göstergesi. Fotoğraf diske YAZILMAZ (CLAUDE.md Altın Kural 1).

**Görev 3 - Ölçüm modülü:** `lib/olcum/` - landmark -> oran vektörü (interpupiller normalize);
sabit landmark fikstürüyle birim + determinizm golden testleri.

**Görev 4 - Kalite kapıları:** yaw/pitch/roll eşikleri + ışık kontrolü; uygunsuzsa nazik yönlendirme.
