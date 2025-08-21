// ✅ Правильный подход:
class GoodExamples {
  void safeListAccess(List<String> items) {
    // ✅ Проверка перед доступом
    if (items.isNotEmpty) {
      final first = items[0];
    }
    
    // ✅ Использование безопасных методов
    final firstElement = items.elementAtOrNull(0);
    
    // ✅ Проверка геттеров
    final userList = getUserList();
    if (userList.isNotEmpty) {
      final user = userList[0];
    }
  }
}
