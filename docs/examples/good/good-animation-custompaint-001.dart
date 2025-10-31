// ✅ ХОРОШО: CustomPaint с repaint параметром
import 'package:flutter/material.dart';

class GoodAnimatedPainter extends StatefulWidget {
  const GoodAnimatedPainter({super.key});

  @override
  State<GoodAnimatedPainter> createState() => _GoodAnimatedPainterState();
}

class _GoodAnimatedPainterState extends State<GoodAnimatedPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // ✅ НЕ нужен addListener!
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // ✅ Передаем Animation напрямую - без rebuilds!
      painter: AnimatedCirclePainter(progress: _controller),
      child: Container(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedCirclePainter extends CustomPainter {
  AnimatedCirclePainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final radius = size.width * 0.4 * progress.value;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(AnimatedCirclePainter old) {
    // ✅ Сравниваем Animation объекты
    return !identical(old.progress, progress);
  }
}

