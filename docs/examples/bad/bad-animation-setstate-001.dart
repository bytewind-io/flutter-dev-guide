// ❌ ПЛОХО: setState на каждом кадре = 60 rebuilds/sec
import 'dart:math';
import 'package:flutter/material.dart';

class BadSpinningWidget extends StatefulWidget {
  const BadSpinningWidget({super.key});

  @override
  State<BadSpinningWidget> createState() => _BadSpinningWidgetState();
}

class _BadSpinningWidgetState extends State<BadSpinningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // ❌ setState на каждом кадре = полный rebuild всего виджета!
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Весь виджет пересобирается 60 раз в секунду
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
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

