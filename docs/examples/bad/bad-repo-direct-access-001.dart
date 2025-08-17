import 'package:flutter/widgets.dart';
import '../data/things_repository.dart'; // ❌ импорт конкретной реализации

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ Неправильно: создание конкретного репозитория в UI
    final repo = ThingsRepository(base: SomeBaseDataApi());
    // repo.fetch(...);
    return const SizedBox.shrink();
  }
}

// Заглушки для примера
class SomeBaseDataApi {}
class ThingsRepository {
  ThingsRepository({required SomeBaseDataApi base});
}
