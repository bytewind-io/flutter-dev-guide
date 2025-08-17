import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../domain/things_repository_i.dart'; // ✅ импорт интерфейса

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Правильно: зависимость от абстракции, реализация провалена DI/Provider
    final repo = context.read<ThingsRepositoryI>();
    // final items = await repo.fetch(const EmptyFilter());
    return const SizedBox.shrink();
  }
}

// Заглушки для примера
abstract class ThingsRepositoryI {
  Future<void> dispose();
}
class EmptyFilter {
  const EmptyFilter();
}
