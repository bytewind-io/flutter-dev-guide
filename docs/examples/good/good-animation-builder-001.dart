// ✅ ХОРОШО: AnimatedBuilder пересобирает только необходимую часть
import 'dart:math';
import 'package:flutter/material.dart';

class GoodSpinningWidget extends StatefulWidget {
  const GoodSpinningWidget({super.key});

  @override
  State<GoodSpinningWidget> createState() => _GoodSpinningWidgetState();
}

class _GoodSpinningWidgetState extends State<GoodSpinningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    // ✅ НЕ нужен addListener с setState!
  }

  @override
  Widget build(BuildContext context) {
    // ✅ AnimatedBuilder пересобирает только Transform.rotate
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child, // Не пересоздается!
        );
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
        child: const Center(
          child: Text('Spinning'),
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

