/// Oran hesaplayıcının kullandığı MediaPipe FaceMesh (478 nokta, iris dahil)
/// landmark indeksleri. Tek doğruluk kaynağı — kodda çıplak sayı kullanılmaz.
///
/// İndeksler MediaPipe FaceMesh kanonik topolojisine dayanır; iris (refine)
/// noktaları 468..477'dir. Gerçek cihaz doğrulamasında küçük ayar gerekebilir
/// (fikstür ve golden bunları sabitler).
abstract final class Li {
  // İris merkezleri (interpupiller mesafe / IPD normalizasyonu için).
  static const int irisSagMerkez = 468;
  static const int irisSolMerkez = 473;

  // Yüz sınırları.
  static const int alinUst = 10;
  static const int ceneAlt = 152;
  static const int yanakSag = 234; // zigoma (görüntüde sol)
  static const int yanakSol = 454; // zigoma (görüntüde sağ)
  static const int ortaYanakSag = 205;
  static const int ortaYanakSol = 425;

  // Çene (bigonial).
  static const int ceneKoseSag = 172;
  static const int ceneKoseSol = 397;

  // Alın genişliği (şakak).
  static const int sakakSag = 54;
  static const int sakakSol = 284;

  // Kaşlar (sağ kaş referans alınır).
  static const int kasIcSag = 55;
  static const int kasIcSol = 285;
  static const int kasTepeSag = 105; // kaş üst tepe
  static const int kasAltSag = 52; // kaş alt
  static const int kasDisSag = 46; // kaş dış uç üst
  static const int kasDisAltSag = 53; // kaş dış uç alt

  // Gözler.
  static const int gozDisSag = 33;
  static const int gozIcSag = 133;
  static const int gozUstKapakSag = 159;
  static const int gozAltKapakSag = 145;
  static const int gozIcSol = 362;
  static const int gozDisSol = 263;

  // Burun.
  static const int nasion = 168; // burun kökü
  static const int burunSirtOrta = 6;
  static const int subnasale = 2; // burun tabanı
  static const int burunUcu = 1;
  static const int burunUcAlt = 4;
  static const int alarSag = 129;
  static const int alarSol = 358;
  static const int burunDelikUstSag = 45;
  static const int burunDelikUstSol = 275;

  // Ağız / dudak.
  static const int agizKoseSag = 61;
  static const int agizKoseSol = 291;
  static const int ustDudakTepe = 0;
  static const int altDudakAlt = 17;

  /// Girdinin geçerli sayılması için gereken en küçük landmark sayısı (iris dahil).
  static const int gerekliNoktaSayisi = 478;
}
