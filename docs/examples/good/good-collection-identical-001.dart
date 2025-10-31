// ✅ ХОРОШО: identical() для O(1) проверки ссылки
import 'package:flutter/material.dart';

class GoodCollectionPainter extends CustomPainter {
  final List<Offset> points;

  GoodCollectionPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем точки
    final paint = Paint()..color = Colors.red;
    for (var point in points) {
      canvas.drawCircle(point, 5.0, paint);
    }
  }

  @override
  bool shouldRepaint(GoodCollectionPainter oldDelegate) {
    // ✅ O(1) проверка ссылки - одна инструкция процессора!
    return !identical(oldDelegate.points, points);
  }
}

class GoodCollectionWidget extends StatefulWidget {
  final List<String> items;

  const GoodCollectionWidget({super.key, required this.items});

  @override
  State<GoodCollectionWidget> createState() => _GoodCollectionWidgetState();
}

class _GoodCollectionWidgetState extends State<GoodCollectionWidget> {
  @override
  void didUpdateWidget(GoodCollectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ O(1) сравнение - мгновенно даже для огромных списков
    if (identical(oldWidget.items, widget.items)) {
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

