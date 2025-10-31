// ❌ ПЛОХО: GlobalKey без необходимости
import 'package:flutter/material.dart';

class BadGlobalKeyWidget extends StatefulWidget {
  const BadGlobalKeyWidget({super.key});

  @override
  State<BadGlobalKeyWidget> createState() => _BadGlobalKeyWidgetState();
}

class _BadGlobalKeyWidgetState extends State<BadGlobalKeyWidget> {
  // ❌ GlobalKey для получения RenderBox
  final GlobalKey _key = GlobalKey();

  void _showMenuAtPosition() {
    // ❌ Используем GlobalKey для получения позиции
    final RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
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
      onTap: _showMenuAtPosition,
      child: Container(
        key: _key, // ❌ GlobalKey прикреплен к виджету
        width: 100,
        height: 50,
        color: Colors.blue,
        child: const Center(child: Text('Menu')),
      ),
    );
  }
}

