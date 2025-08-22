// ❌ Примеры, когда правило должно применяться:
class BadExamples {
  void unsafeListAccess(List<String> items) {
    // ❌ Прямой доступ без проверки
    final first = items[0];
    final second = items[1];
    
    // ❌ Использование first/last без проверки
    final firstElement = items.first;
    final lastElement = items.last;
    
    // ❌ Доступ к элементам через геттеры
    final user = getUserList()[0]; // getUserList() может вернуть пустой список
  }
}
