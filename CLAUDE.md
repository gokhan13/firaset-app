# Marifetname Uygulaması (çalışma adı: Firaset)

Erzurumlu İbrahim Hakkı'nın Marifetname'sindeki (1757) kıyafetname geleneğini modern bir
mobil deneyime çeviren uygulama. Kullanıcı yüzünü taratır, Marifetname'nin gözünden bir
"karne" alır; isterse mizaç testini çözer ve iki bakışın sentezini okur.

> Bu dosya deponun anayasasıdır. Her oturumda önce bunu oku. Çelişki durumunda
> ALTIN KURALLAR > docs/kararlar.md > diğer her şey.

## Ürün özü: Üç Mercek
1. **Tarihsel mercek** - Kıyafetname kuralları (content/v1/01) yüz oranlarına uygulanır.
2. **Modern mercek** - Öz-bildirim testleri: mizaç (content/v1/02) + IPIP tabanlı kısa Büyük Beşli.
3. **Sentez** - "1757 seni böyle okurdu, bugünün psikolojisi böyle diyor" karşılaştırma anlatısı.

Konumlama: bilimsel analiz DEĞİL; kültürel miras + öz-düşünüm + eğlence.
"Eğlence ve kültür amaçlıdır" ibaresi onboarding'de ve her raporun altında görünür.

## ALTIN KURALLAR (pazarlıksız - hiçbir görev bunları esnetemez)
1. **Fotoğraf cihazdan çıkmaz.** Görüntü yalnız bellekte işlenir, diske ve sunucuya asla
   yazılmaz/gönderilmez. Sunucuya giden tek şey soyut oran vektörüdür (ör. alin_orani: 0.81).
2. **Hariç kategoriler motor seviyesinde engellidir:** ten rengi, etnisite/din/cinsel yönelim
   çıkarımı, engellilik/tıbbi durum, mahrem bölgeler, sağlık teşhisi, güzellik puanı, cinsiyet
   genellemeleri. Content dosyası değişse bile kod bu bölgeleri İŞLEMEZ (engine'de sabit
   YASAK_BOLGELER listesi + validator etik kapısı).
3. **Determinizm:** Aynı görüntü -> aynı vektör -> aynı karne. Bunu doğrulayan otomatik test
   her değişiklikte çalışır. LLM çıktıları vektör-hash ile önbelleklenir.
4. **18 yaş kapısı:** Reşit olmayan yüz tahmini durumunda analiz nazikçe reddedilir.
5. **Ücretsiz katman LLM çağrısı yapmaz** (şablon birleştirme, maliyet ~0). LLM yalnız
   premium sentez raporunda, proxy üzerinden çalışır. API anahtarı ASLA istemciye gömülmez.
6. **İçerik değişikliği = validator:** `python3 tools/validate_content.py` yeşil değilse commit yok.
7. **Kural seti sürümlenir:** Her rapor, üretildiği içerik sürümünü (content/v1) kaydeder;
   içerik güncellenince eski raporlar değişmez.
8. **Dil çerçevesi:** "Kıyafetname böyle okur / gelenek böyle yorumlar." Kesin hüküm, kader
   dili, teşhis, korkutma yok. Olumsuz huylar yapıcı "gölge yön" diliyle verilir.
9. **Kaynak gösterimi:** Kamu malı Osmanlıca beyit + kendi sadeleştirmemiz. Modern çevirinin
   cümleleri birebir kullanılmaz (telif).

## Depo haritası
```
CLAUDE.md              <- bu dosya (anayasa)
content/v1/            <- bilgi tabanı v1 (SÜRÜMLÜ; değişiklik = yeni alt sürüm + validator)
  01_kiyafetname_kurallari.json   143 kural (100 aktif / 17 karar bekliyor / 26 hariç)
  02_mizac_sistemi.json           4 mizaç + 10 alâmet + 28 maddelik test
  03_ek_moduller.json             seğirme(56), 12 Hayvan takvimi, rüya, nefs mertebeleri
  04_inceleme_tablosu.xlsx        insan incelemesi için (kod bunu OKUMAZ)
  SURUM.md                        sürüm notları ve teyit durumu
docs/                  <- kararlar, yol haritası, hukuk listesi, isim çalışması
prompts/               <- LLM şablonları (sentez raporu) + karne şablon kuralları
tools/validate_content.py <- şema + ETİK doğrulayıcı
app/                   <- Flutter uygulaması (OKUBENI.md ile başla)
```

## İçerik sözleşmesi (content/v1/01)
Kural alanları: id, bolge, deger, ozellikler|esleme, yon(olumlu|olumsuz|notr|karisik),
kanal(kamera_mesh|kamera_goruntu|kamera_el|ses_kaydi|oz_bildirim|yok), sayfa,
durum(yok=onay_bekliyor | haric | haric_onerisi), haric_nedeni, uygulama, not.
- Motor YALNIZ durum=onay_bekliyor (ileride: onaylandi) kuralları yükler.
- `esleme` içinde "(GÖSTERME)" etiketli değerler motor tarafından atlanır.
- MVP kapsamı: kanal=kamera_mesh kuralları + BB-89 itidal bonusu. Diğer kanallar v1.1+.

## Teknik kararlar (özet - ayrıntı ve gerekçe: docs/kararlar.md)
- **Flutter** (tek kod tabanı, iOS+Android). Dil: Dart. State: Riverpod. Yerelleştirme:
  intl/ARB, TÜM kullanıcı metinleri ilk günden locale-keyed (tr ana, en iskeleti hazır).
- **Yüz ölçümü:** MediaPipe Face Landmarker (478 nokta), on-device. Oranlar interpupiller
  mesafeye normalize edilir; kalite kapıları: yaw/pitch/roll eşikleri + ışık kontrolü.
- **Backend v1'de yok** - MVP tamamen offline çalışabilir. Premium sentez için ince proxy
  (Cloudflare Worker / Supabase Edge) v1.1'de; RevenueCat abonelik v1.1'de.
- **Yerel veri:** yalnız sonuç vektörü + karne metni, cihazda şifreli. Görüntü YOK.

## Kod standartları
- `dart format` + `flutter analyze` temiz olmadan iş bitmiş sayılmaz.
- Test öncelikleri: (1) oran hesaplayıcı birim testleri, (2) determinizm golden testi
  (sabit landmark fikstürü -> beklenen vektör), (3) motor: itidal dengeleme testleri.
- Dosya/klasör adları snake_case; public API'lerde doküman yorumu.

## Token disiplini (bu depoda çalışırken)
- Görev başına TEK hedef modül; dokunulacak dosyaları görev tanımında adlandır.
- Büyük özellikte önce plan mode; onaydan sonra uygula.
- content/*.json dosyalarını bağlama KOMPLE yükleme; şema yukarıda, örnek gerekiyorsa
  tek kural oku. Motor ve validator dosyayı zaten programatik okur.
- Uzun oturumda /compact; oturum sonunda docs/kararlar.md'ye yeni karar varsa ekle.

## Durum ve sıradaki işler
- [x] Faz 0: iskelet + bilgi tabanı v1 + validator (bu depo)
- [ ] Faz 1 (insan işi, paralel): akademik neşirle teyit, 17 haric_onerisi kararı, KVKK avukatı
- [ ] Faz 2 (ilk kod görevleri): bkz. app/OKUBENI.md
  1. Flutter projesi oluştur + CI temeli (analyze/test/format)
  2. Kamera + Face Landmarker POC (nokta sayısı ekranda)
  3. Oran hesaplayıcı modülü + birim/golden testler
  4. Kalite kapıları (poz/ışık) + determinizm testi
