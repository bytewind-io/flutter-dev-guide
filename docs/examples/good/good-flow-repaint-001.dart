// ✅ ОТЛИЧНО: FlowDelegate с repaint для анимации без rebuild
import 'package:flutter/material.dart';

class AnimatedFlowExample extends StatefulWidget {
  const AnimatedFlowExample({super.key});

  @override
  State<AnimatedFlowExample> createState() => _AnimatedFlowExampleState();
}

class _AnimatedFlowExampleState extends State<AnimatedFlowExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Flow(
      // ✅ FlowDelegate с repaint минует rebuild виджетов!
      delegate: AnimatedFlowDelegate(
        animation: _controller,
        itemCount: 5,
      ),
      children: List.generate(
        5,
        (i) => Container(
          width: 80,
          height: 80,
          color: Colors.primaries[i % Colors.primaries.length],
          child: Center(child: Text('$i')),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedFlowDelegate extends FlowDelegate {
  AnimatedFlowDelegate({
    required this.animation,
    required this.itemCount,
  }) : super(
          // ✅ КЛЮЧЕВОЙ МОМЕНТ: repaint параметр
          // Минует фазы Build и Element
          // Только Layout и Paint
          repaint: animation,
        );

  final Animation<double> animation;
  final int itemCount;

  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final offset = animation.value * 100.0;

    for (int i = 0; i < itemCount; i++) {
      final childSize = context.getChildSize(i);
      if (childSize == null) continue;

      // Анимированная трансформация для каждого элемента
      final xOffset = (size.width - childSize.width) / 2;
      final yOffset = i * (childSize.height + 20) + offset;

      final matrix = Matrix4.identity()
        ..translate(xOffset, yOffset)
        ..rotateZ(animation.value * 0.5);

      context.paintChild(
        i,
        transform: matrix,
      );
    }
  }

  @override
  bool shouldRepaint(AnimatedFlowDelegate old) {
    // ✅ Сравниваем ссылки на Animation
    return !identical(old.animation, animation) ||
           old.itemCount != itemCount;
  }
}

