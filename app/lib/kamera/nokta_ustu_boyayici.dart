import 'package:flutter/material.dart';

import '../olcum/landmark_motoru.dart';

/// 478 landmark noktasini onizleme uzerine cizen basit boyayici (calistiginin
/// gorsel kaniti). Noktalar normalize (0..1); paint boyutuna olceklenir.
class NoktaUstuBoyayici extends CustomPainter {
  const NoktaUstuBoyayici(this.noktalar);

  final List<Landmark> noktalar;

  @override
  void paint(Canvas canvas, Size size) {
    if (noktalar.isEmpty) return;
    final boya = Paint()
      ..color = const Color(0xFF7C4DFF)
      ..style = PaintingStyle.fill;
    for (final n in noktalar) {
      canvas.drawCircle(Offset(n.x * size.width, n.y * size.height), 1.4, boya);
    }
  }

  @override
  bool shouldRepaint(covariant NoktaUstuBoyayici oldDelegate) =>
      oldDelegate.noktalar != noktalar;
}
