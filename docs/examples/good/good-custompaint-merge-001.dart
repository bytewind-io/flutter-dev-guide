// ✅ ОТЛИЧНО: Listenable.merge() для множественных источников изменений
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AnimatedPointsPainter extends StatefulWidget {
  const AnimatedPointsPainter({super.key});

  @override
  State<AnimatedPointsPainter> createState() => _AnimatedPointsPainterState();
}

class _AnimatedPointsPainterState extends State<AnimatedPointsPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ValueNotifier<List<Offset>> _points = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Симулируем изменение точек
    _points.value = List.generate(
      100,
      (i) => Offset(i * 10.0, 100.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // ✅ Listenable.merge объединяет несколько источников
      // Перерисовка при изменении ЛЮБОГО из них
      painter: MergedListenablePainter(
        animation: _controller,
        points: _points,
      ),
      size: const Size(400, 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _points.dispose();
    super.dispose();
  }
}

class MergedListenablePainter extends CustomPainter {
  MergedListenablePainter({
    required this.animation,
    required this.points,
  }) : super(
          // ✅ КЛЮЧЕВОЙ МОМЕНТ: Listenable.merge()
          // Подписывается на ОБА источника
          // Нотифицирует при изменении ЛЮБОГО
          repaint: Listenable.merge([animation, points]),
        );

  final Animation<double> animation;
  final ValueNotifier<List<Offset>> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(animation.value)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Рисуем точки с учетом обоих источников
    for (var point in points.value) {
      final animatedY = point.dy + (animation.value * 50);
      canvas.drawCircle(
        Offset(point.dx, animatedY),
        5.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MergedListenablePainter old) {
    // ✅ Сравниваем ссылки на источники
    return !identical(old.animation, animation) ||
           !identical(old.points, points);
  }
}

