// ✅ Альтернативные безопасные методы
// elementAtOrNull - возвращает null если индекс вне границ
final user = users.elementAtOrNull(0);

// take() - берет только доступные элементы
final firstTwoUsers = users.take(2).toList();

// where с проверкой длины
if (users.length >= 2) {
  final firstUser = users[0];
  final secondUser = users[1];
  // работа с пользователями
}

// Использование firstWhereOrNull для безопасного поиска
final adminUser = users.firstWhereOrNull((user) => user.role == 'admin');

// Проверка с помощью isEmpty/isNotEmpty
if (users.isNotEmpty) {
  final firstUser = users.first; // Безопасно после проверки
}

// Использование fold для безопасной агрегации
final totalAge = users.fold<int>(0, (sum, user) => sum + user.age);
