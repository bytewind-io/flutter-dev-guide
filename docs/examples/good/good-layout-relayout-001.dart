// ✅ ОТЛИЧНО: MultiChildLayoutDelegate с relayout для анимации layout'а
import 'package:flutter/material.dart';

class AnimatedLayoutExample extends StatefulWidget {
  const AnimatedLayoutExample({super.key});

  @override
  State<AnimatedLayoutExample> createState() => _AnimatedLayoutExampleState();
}

class _AnimatedLayoutExampleState extends State<AnimatedLayoutExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      // ✅ MultiChildLayoutDelegate с relayout
      // Минует фазу Build, но выполняет Layout
      delegate: AnimatedLayoutDelegate(animation: _controller),
      children: [
        LayoutId(
          id: 'header',
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
        LayoutId(
          id: 'content',
          child: Container(
            color: Colors.green,
            child: const Center(
              child: Text(
                'Content',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
        LayoutId(
          id: 'footer',
          child: Container(
            color: Colors.orange,
            child: const Center(
              child: Text(
                'Footer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedLayoutDelegate extends MultiChildLayoutDelegate {
  AnimatedLayoutDelegate({
    required this.animation,
  }) : super(
          // ✅ КЛЮЧЕВОЙ МОМЕНТ: relayout параметр
          // Минует фазу Build виджетов
          // Выполняет только Layout и Paint
          relayout: animation,
        );

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    // Анимированные высоты секций
    final headerHeight = 100.0 + (animation.value * 50);
    final footerHeight = 80.0;
    final contentHeight = size.height - headerHeight - footerHeight;

    // Layout header
    if (hasChild('header')) {
      layoutChild(
        'header',
        BoxConstraints.tightFor(
          width: size.width,
          height: headerHeight,
        ),
      );
      positionChild('header', Offset.zero);
    }

    // Layout content
    if (hasChild('content')) {
      layoutChild(
        'content',
        BoxConstraints.tightFor(
          width: size.width,
          height: contentHeight,
        ),
      );
      positionChild('content', Offset(0, headerHeight));
    }

    // Layout footer
    if (hasChild('footer')) {
      layoutChild(
        'footer',
        BoxConstraints.tightFor(
          width: size.width,
          height: footerHeight,
        ),
      );
      positionChild('footer', Offset(0, headerHeight + contentHeight));
    }
  }

  @override
  bool shouldRelayout(AnimatedLayoutDelegate old) {
    // ✅ Сравниваем ссылки на Animation
    return !identical(old.animation, animation);
  }
}

