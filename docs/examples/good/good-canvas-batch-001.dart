// ✅ ХОРОШО: Используем drawRawPoints для batch-отрисовки
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GoodCanvasPainter extends CustomPainter {
  final List<Offset> points;
  final double radius;

  GoodCanvasPainter({
    required this.points,
    this.radius = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round;

    // ✅ Собираем координаты в Float32List
    final Float32List coords = Float32List(points.length * 2);
    for (int i = 0; i < points.length; i++) {
      coords[i * 2] = points[i].dx;
      coords[i * 2 + 1] = points[i].dy;
    }

    // ✅ ОДНА команда GPU для всех точек!
    canvas.drawRawPoints(
      ui.PointMode.points,
      coords,
      paint,
    );
  }

  @override
  bool shouldRepaint(GoodCanvasPainter oldDelegate) {
    return !identical(oldDelegate.points, points) ||
           oldDelegate.radius != radius;
  }
}

