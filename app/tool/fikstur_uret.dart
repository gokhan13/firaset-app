// Determinizm testleri için sabit landmark fikstürleri üretir.
//
// Kaynak GERÇEK FOTOĞRAF DEĞİLDİR (Altın Kural 1 + gizlilik + telif): oran
// hesaplayıcının kullandığı indeksleri anatomik olarak makul konumlara yerleştiren
// SENTETİK, deterministik bir yüz. Kullanılmayan indeksler nötr dolgu (0.5,0.5,0).
//
// Çalıştırma:  dart run tool/fikstur_uret.dart
// Çıktı:       test/fixtures/*.json  (commit'lenir; testler statik okur)

import 'dart:convert';
import 'dart:io';

const int kEn = 1000;
const int kBoy = 1000;
const int kNokta = 478;

/// Kilit landmark'ların normalize (0..1) konumları [x, y, z].
const Map<int, List<double>> _temelYuz = {
  10: [0.50, 0.12, 0.02], // alın üst
  152: [0.50, 0.92, 0.03], // çene alt
  234: [0.18, 0.45, 0.06], // yanak sağ
  454: [0.82, 0.45, 0.06], // yanak sol
  205: [0.30, 0.55, 0.03], // orta yanak sağ
  425: [0.70, 0.55, 0.03], // orta yanak sol
  172: [0.26, 0.75, 0.05], // çene köşe sağ
  397: [0.74, 0.75, 0.05], // çene köşe sol
  54: [0.28, 0.20, 0.04], // şakak sağ
  284: [0.72, 0.20, 0.04], // şakak sol
  55: [0.42, 0.35, 0.01], // kaş iç sağ
  285: [0.58, 0.35, 0.01], // kaş iç sol
  105: [0.34, 0.33, 0.02], // kaş tepe sağ
  52: [0.34, 0.37, 0.02], // kaş alt sağ
  46: [0.26, 0.35, 0.03], // kaş dış sağ
  53: [0.27, 0.37, 0.03], // kaş dış alt sağ
  33: [0.30, 0.42, 0.02], // göz dış sağ
  133: [0.42, 0.43, 0.01], // göz iç sağ
  159: [0.36, 0.40, 0.01], // göz üst kapak sağ
  145: [0.36, 0.45, 0.01], // göz alt kapak sağ
  362: [0.58, 0.43, 0.01], // göz iç sol
  263: [0.70, 0.42, 0.02], // göz dış sol
  168: [0.50, 0.38, 0.00], // nasion
  6: [0.50, 0.45, -0.01], // burun sırtı orta
  2: [0.50, 0.60, -0.03], // subnasale
  1: [0.50, 0.57, -0.06], // burun ucu
  4: [0.50, 0.55, -0.05], // burun ucu alt
  129: [0.43, 0.60, -0.01], // alar sağ
  358: [0.57, 0.60, -0.01], // alar sol
  45: [0.45, 0.58, -0.03], // burun deliği üst sağ
  275: [0.55, 0.58, -0.03], // burun deliği üst sol
  61: [0.38, 0.72, 0.01], // ağız köşe sağ
  291: [0.62, 0.72, 0.01], // ağız köşe sol
  0: [0.50, 0.68, -0.01], // üst dudak tepe
  17: [0.50, 0.77, 0.00], // alt dudak alt
  468: [0.36, 0.425, 0.015], // iris merkez sağ
  473: [0.64, 0.425, 0.015], // iris merkez sol
};

List<List<double>> _yuzKur(Map<int, List<double>> ozel) {
  final noktalar = List<List<double>>.generate(
    kNokta,
    (_) => <double>[0.5, 0.5, 0.0],
  );
  ozel.forEach((i, p) => noktalar[i] = List<double>.from(p));
  return noktalar;
}

/// Y eksenini merkez etrafında [k] kat gerer (uzun yüz).
Map<int, List<double>> _dikeyGer(Map<int, List<double>> m, double k) => {
  for (final e in m.entries)
    e.key: [e.value[0], 0.5 + (e.value[1] - 0.5) * k, e.value[2]],
};

/// Ağız köşelerini dışa açar (geniş ağız).
Map<int, List<double>> _agziGenislet(Map<int, List<double>> m, double d) {
  final kopya = {for (final e in m.entries) e.key: List<double>.from(e.value)};
  kopya[61]![0] -= d;
  kopya[291]![0] += d;
  return kopya;
}

void _yaz(String ad, Map<int, List<double>> ozel) {
  final data = {
    'aciklama': 'Sentetik deterministik yuz fiksturu (gercek foto degil).',
    'enPiksel': kEn,
    'boyPiksel': kBoy,
    'noktalar': _yuzKur(ozel),
  };
  final dosya = File('test/fixtures/$ad.json');
  dosya.parent.createSync(recursive: true);
  dosya.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  stdout.writeln('yazildi: ${dosya.path}');
}

void main() {
  _yaz('yuz_dengeli', _temelYuz);
  _yaz('yuz_uzun', _dikeyGer(_temelYuz, 1.2));
  _yaz('yuz_genis_agiz', _agziGenislet(_temelYuz, 0.06));
}
