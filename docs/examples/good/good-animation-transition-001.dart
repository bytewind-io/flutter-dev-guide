// ✅ ЕЩЕ ЛУЧШЕ: RotationTransition - оптимизированный виджет без rebuilds
import 'package:flutter/material.dart';

class GoodRotationWidget extends StatefulWidget {
  const GoodRotationWidget({super.key});

  @override
  State<GoodRotationWidget> createState() => _GoodRotationWidgetState();
}

class _GoodRotationWidgetState extends State<GoodRotationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Оптимизированный виджет без rebuilds
    return RotationTransition(
      turns: _controller,
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

