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

```dart
--8<-- "docs/examples/bad/bad-list-access-001.dart"
```

**Проблемы:**
- Обращение к `model.getSecondUser` без проверки на null
- Обращение к `model.getFirstUser` без проверки на null
- Нет проверки длины списка перед обращением к элементам
- Потенциальный краш при пустом списке пользователей

## Хорошо

```dart
--8<-- "docs/examples/good/good-list-access-001.dart"
```

**Преимущества:**
- Проверка `hasUsers` перед обращением к элементам
- Проверка `users.length < 2` перед обращением к `users[1]`
- Безопасный доступ к элементам массива
- Fallback виджеты для edge cases
- Разделение логики на отдельные методы для читаемости

## Альтернативные безопасные методы

```dart
--8<-- "docs/examples/good/good-list-access-002.dart"
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
--8<-- "docs/examples/bad/bad-list-access-002.dart"
```

```dart
--8<-- "docs/examples/good/good-list-access-003.dart"
```
