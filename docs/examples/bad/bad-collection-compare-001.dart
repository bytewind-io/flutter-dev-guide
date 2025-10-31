// ❌ ПЛОХО: listEquals перебирает весь список на каждом кадре
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BadCollectionPainter extends CustomPainter {
  final List<Offset> points;

  BadCollectionPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем точки
    final paint = Paint()..color = Colors.red;
    for (var point in points) {
      canvas.drawCircle(point, 5.0, paint);
    }
  }

  @override
  bool shouldRepaint(BadCollectionPainter oldDelegate) {
    // ❌ O(n) сравнение на каждом кадре!
    return !listEquals(oldDelegate.points, points);
  }
}

class BadCollectionWidget extends StatefulWidget {
  final List<String> items;

  const BadCollectionWidget({super.key, required this.items});

  @override
  State<BadCollectionWidget> createState() => _BadCollectionWidgetState();
}

class _BadCollectionWidgetState extends State<BadCollectionWidget> {
  @override
  void didUpdateWidget(BadCollectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ❌ O(n) сравнение на каждый rebuild
    if (listEquals(oldWidget.items, widget.items)) {
      return;
    }
    _updateItems();
  }

  void _updateItems() {
    // Обновление данных
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.items.map((e) => Text(e)).toList(),
    );
  }
}

