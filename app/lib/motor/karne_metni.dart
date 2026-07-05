import 'karne.dart';

/// Karne'den saf ŞABLON metin üretir (LLM YOK — ücretsiz katman, Altın Kural 5).
///
/// Madde metinleri YALNIZ [Karne.yorumlar] içindeki `metin` (= içerik `uygulama`
/// alanı) ve BB-89 bonus metnidir; ham `ozellikler`/`esleme` girmez. Çerçeve
/// dizeleri ([baslik]/[disclaimer]) dışarıdan (l10n) verilir. Kesin hüküm/kader
/// dili eklenmez; olumsuzlar zaten editör onaylı yumuşatılmış uygulama metnidir.
String karneMetni(
  Karne k, {
  required String baslik,
  required String disclaimer,
}) {
  final b = StringBuffer()
    ..writeln(baslik)
    ..writeln();
  for (final y in k.yorumlar) {
    b.writeln('• ${y.metin}');
  }
  final bonus = k.itidal.bonusMetin;
  if (bonus != null) {
    b.writeln('• $bonus');
  }
  b
    ..writeln()
    ..writeln(disclaimer);
  return b.toString().trimRight();
}
