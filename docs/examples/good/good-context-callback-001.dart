// ✅ ХОРОШО: Передаем контекст через callback
import 'package:flutter/material.dart';

class GoodParentWidget extends StatelessWidget {
  const GoodParentWidget({super.key});

  void _handleChildTap(BuildContext childContext) {
    // ✅ Контекст передан через параметр
    final RenderBox box = childContext.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    showMenu(
      context: childContext,
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
    return GoodChildWidget(
      onTap: _handleChildTap,
    );
  }
}

class GoodChildWidget extends StatelessWidget {
  final void Function(BuildContext) onTap;

  const GoodChildWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 100,
        height: 50,
        color: Colors.blue,
        child: const Center(child: Text('Menu')),
      ),
    );
  }
}

