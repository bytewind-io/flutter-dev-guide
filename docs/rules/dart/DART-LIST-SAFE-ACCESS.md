---
id: DART-LIST-SAFE-ACCESS
title: "Безопасный доступ к элементам списка с проверкой индексов"
status: stable
severity: error
category: dart/lists
tags: [list, array, index, bounds, crash]
linter_rule:
coverage: ai
bad_snippet: bad-list-access-001.dart
good_snippet: good-list-access-001.dart
references: []
ai_hint: >
  Always check list bounds before accessing elements by index.
  Use safe access methods like elementAtOrNull or conditional checks.
---

## Пояснение

При работе со списками необходимо всегда проверять границы массива перед обращением к элементам по индексу. Обращение к несуществующему индексу приводит к `RangeError` и краху приложения.

## Основные принципы

1. **Проверяем длину списка** перед обращением по индексу
2. **Используем безопасные методы** доступа к элементам
3. **Обрабатываем случаи** когда список пуст или недостаточно элементов
4. **Избегаем хардкода индексов** без валидации

## Плохо

```dart title="docs/examples/bad/bad-list-access-001.dart"

// ❌ Обращение к элементам списка без проверки границ
class ConversationListItem extends StatelessWidget {
  final ConversationModel model;
  
  const ConversationListItem({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          // ❌ Обращение к элементам без проверки длины
          if (model.conversationUsers.length == 1)
            UserAvatarFromUserModelWidget(
              size: MetricsSizes.size20,
              user: model.getFirstUser,
            )
          else if (model.type == ConversationType.privateConversation)
            UserAvatarFromUserModelWidget(
              size: MetricsSizes.size20,
              user: model.getFirstUser.name == model.name 
                ? model.getFirstUser 
                : model.getSecondUser,
            )
          else
            SizedBox(
              width: MetricsSizes.size40,
              height: MetricsSizes.size40,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  // ❌ Краш при пустом списке - нет проверки
                  UserAvatarFromUserModelWidget.fromUser(
                    size: MetricsSizes.size14,
                    user: model.getSecondUser, // ❌ Может быть null
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: UserAvatarFromUserModelWidget.fromUser(
                        size: 13.25,
                        user: model.getFirstUser, // ❌ Может быть null
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ❌ Другие примеры небезопасной работы со списками
class BadListExamples {
  void unsafeAccess(List<String> items) {
    // ❌ Прямой доступ без проверки
    final first = items[0]; // Краш если список пуст
    final last = items[items.length - 1]; // Краш если список пуст
    
    // ❌ Использование first/last без проверки
    final firstElement = items.first; // Краш если список пуст
    final lastElement = items.last; // Краш если список пуст
    
    // ❌ Доступ к нескольким элементам без проверки
    if (items.length > 0) {
      final first = items[0]; // ✅ Проверили первый элемент
      final second = items[1]; // ❌ Но не проверили второй!
    }
  }
  
  void unsafeIteration(List<int> numbers) {
    // ❌ Итерация с фиксированными индексами
    for (int i = 0; i < 5; i++) {
      print(numbers[i]); // ❌ Краш если в списке меньше 5 элементов
    }
  }
}
```

**Проблемы:**
- Обращение к `model.getSecondUser` без проверки на null
- Обращение к `model.getFirstUser` без проверки на null
- Нет проверки длины списка перед обращением к элементам
- Потенциальный краш при пустом списке пользователей

## Хорошо

```dart
// ✅ Безопасный доступ к элементам списка с проверкой границ
class ConversationListItem extends StatelessWidget {
  final ConversationModel model;
  
  const ConversationListItem({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final conversationUsers = model.conversationUsers;
    final hasUsers = conversationUsers.isNotEmpty;
    
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          switch (model.type) {
            ConversationType.privateConversation => _buildPrivateAvatar(),
            ConversationType.group => hasUsers && conversationUsers.length == 1
                ? UserAvatarFromUserModelWidget(
                    size: MetricsSizes.size20,
                    user: conversationUsers[0], // ✅ Безопасно - проверили длину
                  )
                : _buildGroupAvatars(conversationUsers),
          },
        ],
      ),
    );
  }

  Widget _buildPrivateAvatar() {
    // ✅ Безопасный доступ с проверкой
    final firstUser = model.getFirstUser;
    final secondUser = model.getSecondUser;
    
    if (firstUser == null || secondUser == null) {
      return const SizedBox.shrink(); // ✅ Fallback для null значений
    }
    
    return UserAvatarFromUserModelWidget(
      size: MetricsSizes.size20,
      user: firstUser.name == model.name ? firstUser : secondUser,
    );
  }

  Widget _buildGroupAvatars(List<UserModel> users) {
    // ✅ Проверяем наличие достаточного количества элементов
    if (users.length < 2) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: MetricsSizes.size40,
      height: MetricsSizes.size40,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          UserAvatarFromUserModelWidget.fromUser(
            size: MetricsSizes.size14,
            user: users[0], // ✅ Безопасно - проверили длину
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: UserAvatarFromUserModelWidget.fromUser(
                size: 13.25,
                user: users[1], // ✅ Безопасно - проверили длину
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Другие примеры безопасной работы со списками
class GoodListExamples {
  void safeAccess(List<String> items) {
    // ✅ Проверка перед доступом
    if (items.isNotEmpty) {
      final first = items[0]; // Безопасно
      final last = items[items.length - 1]; // Безопасно
    }
    
    // ✅ Использование безопасных методов
    final firstElement = items.elementAtOrNull(0); // Возвращает null если индекс вне границ
    final lastElement = items.elementAtOrNull(items.length - 1);
    
    // ✅ Проверка достаточного количества элементов
    if (items.length >= 2) {
      final first = items[0];
      final second = items[1];
      // работа с элементами
    }
  }
  
  void safeIteration(List<int> numbers) {
    // ✅ Итерация с проверкой границ
    for (int i = 0; i < numbers.length && i < 5; i++) {
      print(numbers[i]); // Безопасно
    }
    
    // ✅ Использование take для ограничения количества элементов
    final limitedNumbers = numbers.take(5).toList();
    for (final number in limitedNumbers) {
      print(number); // Безопасно
    }
  }
  
  void safeBatchAccess(List<UserModel> users) {
    // ✅ Проверка перед доступом к нескольким элементам
    if (users.length >= 3) {
      final first = users[0];
      final second = users[1];
      final third = users[2];
      // работа с тремя пользователями
    } else if (users.length >= 2) {
      final first = users[0];
      final second = users[1];
      // работа с двумя пользователями
    } else if (users.isNotEmpty) {
      final first = users[0];
      // работа с одним пользователем
    } else {
      // список пуст
    }
  }
}
```

**Преимущества:**
- Проверка `hasUsers` перед обращением к элементам
- Проверка `users.length < 2` перед обращением к `users[1]`
- Безопасный доступ к элементам массива
- Fallback виджеты для edge cases
- Разделение логики на отдельные методы для читаемости

## Альтернативные безопасные методы

```dart
// ✅ elementAtOrNull - возвращает null если индекс вне границ
final user = users.elementAtOrNull(0);

// ✅ take() - берет только доступные элементы
final firstTwoUsers = users.take(2).toList();

// ✅ where с проверкой длины
if (users.length >= 2) {
  final firstUser = users[0];
  final secondUser = users[1];
  // работа с пользователями
}

// ✅ Использование firstWhereOrNull для безопасного поиска
final adminUser = users.firstWhereOrNull((user) => user.role == 'admin');

// ✅ Проверка с помощью isEmpty/isNotEmpty
if (users.isNotEmpty) {
  final firstUser = users.first; // Безопасно после проверки
}

// ✅ Использование fold для безопасной агрегации
final totalAge = users.fold<int>(0, (sum, user) => sum + user.age);
```

## Когда правило применяется

- Обращение к элементам списка по индексу
- Использование методов `first`, `last` без проверки длины
- Доступ к элементам через геттеры без валидации
- Работа с динамическими списками неизвестной длины
- Итерация по фиксированным индексам без проверки границ
- Доступ к нескольким элементам подряд без валидации
- Работа с результатами API, которые могут быть пустыми

```dart
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
```
