// ❌ ПЛОХО: Цикл с draw методами убивает FPS
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BadCanvasPainter extends CustomPainter {
  final List<Offset> points;
  final double radius;

  BadCanvasPainter({
    required this.points,
    this.radius = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;

    // ❌ 1000 команд GPU! Каждый вызов drawCircle - отдельная команда
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        Offset(points[i].dx, points[i].dy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BadCanvasPainter oldDelegate) {
    return !identical(oldDelegate.points, points) ||
           oldDelegate.radius != radius;
  }
}

