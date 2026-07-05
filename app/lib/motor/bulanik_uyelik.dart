import 'esikler_gecici.dart';

/// Bir metriğin düştüğü dilim.
enum Dilim { alt, orta, ust }

/// Bir oranın üç dilime bulanık üyeliği (her biri 0..1).
class DilimUyeligi {
  const DilimUyeligi({
    required this.alt,
    required this.orta,
    required this.ust,
  });

  final double alt;
  final double orta;
  final double ust;

  double operator [](Dilim d) => switch (d) {
    Dilim.alt => alt,
    Dilim.orta => orta,
    Dilim.ust => ust,
  };
}

/// [oran]'ın [e] bandına trapez bulanık üyeliği.
///
/// `norm` = merkeze uzaklık / yarı-bant (0 merkez, ±1 bant kenarı). Orta dilim
/// |norm|≤1 iken 1, |norm|=2'de 0'a iner; alt/üst dilimler simetrik ramp.
/// `yontem.bulanik_oneri` (kesin eşik yerine dilim) ruhuna uygundur.
DilimUyeligi uyelik(double oran, EsikBandi e) {
  final yariBant = (e.merkez * e.bant).abs();
  if (yariBant == 0) {
    return const DilimUyeligi(alt: 0, orta: 1, ust: 0);
  }
  final norm = (oran - e.merkez) / yariBant;
  double c(double v) => v.clamp(0.0, 1.0);

  final asim = (norm.abs() - 1).clamp(0.0, double.infinity);
  return DilimUyeligi(alt: c(-norm - 1), orta: c(1 - asim), ust: c(norm - 1));
}
