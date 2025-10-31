// ✅ ХОРОШО: Получаем RenderBox из контекста напрямую
import 'package:flutter/material.dart';

class GoodContextWidget extends StatelessWidget {
  const GoodContextWidget({super.key});

  void _showMenuAt(BuildContext context) {
    // ✅ Получаем RenderBox из контекста
    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + box.size.width,
        position.dy + box.size.height,
      ),
      items: [
        const PopupMenuItem(child: Text('Option 1')),
        const PopupMenuItem(child: Text('Option 2')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenuAt(context),
      child: Container(
        width: 100,
        height: 50,
        color: Colors.blue,
        child: const Center(child: Text('Menu')),
      ),
    );
  }
}

