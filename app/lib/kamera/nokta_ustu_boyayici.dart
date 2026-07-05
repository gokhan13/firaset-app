import 'package:flutter/material.dart';

import '../olcum/landmark_motoru.dart';
import 'onizleme_donusumu.dart';

/// 478 landmark noktasını önizleme dokusunun üstüne çizer.
///
/// Noktalar [donusum] ile gösterim uzayına taşınır; doku ile aynı dönüşümü
/// paylaştıkları için hizalanırlar. [debug] açıkken hizalama doğrulaması için
/// iris merkezleri (yeşil, gözbebeğine oturmalı) ve çene ucu (kırmızı) vurgulanır.
class NoktaUstuBoyayici extends CustomPainter {
  const NoktaUstuBoyayici({
    required this.noktalar,
    required this.donusum,
    this.debug = false,
  });

  final List<Landmark> noktalar;
  final OnizlemeDonusumu donusum;
  final bool debug;

  // Hizalama doğrulaması için işaretçi indeksleri (MediaPipe FaceMesh + iris).
  static const int _irisSag = 468;
  static const int _irisSol = 473;
  static const int _ceneUcu = 152;

  @override
  void paint(Canvas canvas, Size size) {
    if (noktalar.isEmpty) return;

    final nokta = Paint()
      ..color = const Color(0xB37C4DFF)
      ..style = PaintingStyle.fill;
    for (final l in noktalar) {
      canvas.drawCircle(donusum.noktaGosterime(l.x, l.y), 1.4, nokta);
    }

    if (debug) {
      void isaret(int i, Color renk) {
        if (i >= noktalar.length) return;
        final l = noktalar[i];
        canvas.drawCircle(
          donusum.noktaGosterime(l.x, l.y),
          6,
          Paint()..color = renk,
        );
      }

      // Yeşil: iris merkezleri → gözbebeğine oturmalı.
      isaret(_irisSag, const Color(0xFF00E676));
      isaret(_irisSol, const Color(0xFF00E676));
      // Kırmızı: çene ucu → çeneye oturmalı.
      isaret(_ceneUcu, const Color(0xFFFF1744));
    }
  }

  @override
  bool shouldRepaint(covariant NoktaUstuBoyayici oldDelegate) => true;
}
