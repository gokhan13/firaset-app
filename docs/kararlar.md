# Karar Kayıtları (ADR)
Her önemli karar buraya bir satır: NE, NEDEN, TARİH. Kararı değiştirmek = yeni kayıt.

- **D-001** (2026-07-04) Konumlama: "bilimsel analiz" değil, kültürel miras + eğlence + öz-düşünüm.
  Neden: bilimsel savunulamazlık, mağaza reddi ve AB YZ Yasası riski tek kararla çözülüyor.
- **D-002** (2026-07-04) Fotoğraf cihazdan çıkmaz (on-device pipeline). Neden: KVKK özel nitelikli
  veri riskini minimize eder; pazarlama vaadi olur.
- **D-003** (2026-07-04) Hariç kategoriler hem içerikte işaretli hem KODDA sabit engelli.
  Neden: içerik dosyası tek koruma katmanı olamaz.
- **D-004** (2026-07-05) Ücretsiz katman LLM'siz (şablon birleştirme); LLM yalnız premium sentezde,
  prompt caching + vektör-hash önbelleğiyle. Neden: birim ekonomi + determinizm.
- **D-005** (2026-07-05) Modern test: IPIP tabanlı kısa Büyük Beşli. MBTI kullanılmaz.
  Neden: IPIP kamu malı; MBTI tescilli marka.
- **D-006** (2026-07-05) İçerik sürümleme: content/vN klasörleri; rapor, üretildiği sürümü kaydeder.
  Neden: kural değişince eski karneler sessizce değişmesin.
- **D-007** (2026-07-05) 12 Hayvan hesabı: yıl Nevruz (~21 Mart) başlangıçlı, 4'er aylık üç dönem;
  çevrim referansı 2020=Sıçan. Metnin hicri formülü akademik teyit sonrası eklenebilir.
- **D-008** (2026-07-05) Motor: bulanık üyelik + itidal dengelemesi (zıt deliller nötrler,
  çoğunluk kazanır) + BB-89 itidal bonusu. Kaynak: Nevi 7, s.435.
- **D-009** (2026-07-05) 18 yaş kapısı: reşit olmayan yüz tahmininde analiz reddi. Neden: etik + mağaza.
- **D-010** (2026-07-05) Kaynak gösterimi kamu malı beyit + kendi sadeleştirmemizle; modern çeviri
  cümleleri birebir kullanılmaz. Neden: telif.
- **D-011** (2026-07-05) MVP ölçüm kapsamı yalnız kamera_mesh kuralları; el/ses/öz-bildirim kanalları v1.1+.
  Neden: odak + App Review basitliği.
- **D-012** (2026-07-05) Backend'siz MVP; premium için ince proxy v1.1. API anahtarı istemciye gömülmez.
- **D-013** (2026-07-05) Flutter sürümü **3.44.4** (stable, Dart 3.12.2) pinlendi; `app/.flutter-version`
  ve CI aynı sürümü kullanır. Neden: determinizm golden testleri sabit SDK ister (Altın Kural 3).
- **D-014** (2026-07-05) Uygulama org/bundle öneki **com.aboa** (bundle: `com.aboa.firaset`).
  Neden: kurucunun alan adı aboa.com.tr; App Store/Play kalıcı kimliği. `flutter create --org com.aboa`.
- **D-015** (2026-07-05) `app/pubspec.lock` commit'lenir (kök `.gitignore`'da `!app/pubspec.lock` istisnası).
  Neden: uygulama projesi; bağımlılık sürümlerini kilitlemek determinizmi güçlendirir (Altın Kural 3).
