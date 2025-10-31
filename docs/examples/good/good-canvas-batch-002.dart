// ✅ ХОРОШО: Используем drawPath для сложных фигур
import 'dart:math';
import 'package:flutter/material.dart';

class GoodCanvasPathPainter extends CustomPainter {
  final int count;
  final Rect rect;
  final double arcLength;

  GoodCanvasPathPainter({
    required this.count,
    required this.rect,
    required this.arcLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final step = (2 * pi) / count;

    // ✅ Собираем все дуги в один Path
    final Path path = Path();
    for (double i = pi / (count * 2); i < pi * 2; i += step) {
      path.addArc(rect, i, arcLength);
    }

    // ✅ Один вызов drawPath вместо множества drawArc
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GoodCanvasPathPainter oldDelegate) {
    return oldDelegate.count != count ||
           oldDelegate.rect != rect ||
           oldDelegate.arcLength != arcLength;
  }
}

