---
id: DART-DATA-ENUM-UNKNOWN
title: "Неизвестные значения enum: предпочитай null; допускается ItemType.unknown"
status: stable
severity: warning
category: dart/enums
tags: [enum, robustness]
linter_rule:
coverage: ai
bad_snippet: bad-enum-unknown-001.dart
good_snippet: good-enum-unknown-001.dart
references: []
ai_hint: >
  For unknown enum inputs prefer null. If domain requires non-null, provide explicit unknown variant.
---

## Описание правила

При парсинге enum'ов из внешних данных (JSON, API) могут встречаться неизвестные значения. По умолчанию следует возвращать `null`, но если логика требует non-null, допускается использование специального `unknown` варианта.

## Основные принципы

1. **По умолчанию возвращаем `null`** для неизвестных значений
2. **Допускается `unknown` вариант**, если логика требует non-null
3. **Явная обработка** неизвестных значений
4. **Robustness** - устойчивость к некорректным данным

## Плохо

```dart title="docs/examples/bad/bad-enum-unknown-001.dart"

enum ItemType {
  book(1),
  movie(2),
  music(3);

  const ItemType(this.value);
  final int value;

  static ItemType fromValue(int raw) {
    // ❌ Может выбросить исключение для неизвестных значений
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    throw ArgumentError('Unknown ItemType: $raw'); // ❌ Исключение
  }
}

class Item {
  const Item({required this.type});
  final ItemType type;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      type: ItemType.fromValue(json['type'] as int), // ❌ Может упасть
    );
  }
}
```

**Проблемы:**
- Исключение при неизвестных значениях
- Приложение может упасть на некорректных данных
- Отсутствует graceful degradation
- Нет явной обработки ошибок

## Хорошо

```dart:docs/examples/good/good-enum-unknown-001.dart
enum ItemType {
  book(1),
  movie(2),
  music(3);

  const ItemType(this.value);
  final int value;

  static ItemType? fromValue(int? raw) {
    if (raw == null) return null;
    
    // ✅ Возвращаем null для неизвестных значений
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    return null; // ✅ Безопасно для неизвестных значений
  }
}

class Item {
  const Item({required this.type});
  final ItemType type;

  factory Item.fromJson(Map<String, dynamic> json) {
    final type = ItemType.fromValue(json['type'] as int?);
    if (type == null) {
      // ✅ Явная обработка неизвестного типа
      throw ArgumentError('Unknown ItemType: ${json['type']}');
    }
    
    return Item(type: type);
  }
}
```

**Преимущества:**
- Безопасность: `null` для неизвестных значений
- Явная обработка: можно решить, что делать с неизвестными данными
- Robustness: приложение не падает на некорректных данных
- Гибкость: можно выбрать стратегию обработки

## Альтернативный подход с unknown

Если логика требует non-null, можно добавить специальный `unknown` вариант:

```dart
enum ItemType {
  book(1),
  movie(2),
  music(3),
  unknown(-1); // ✅ Специальный вариант для неизвестных значений

  const ItemType(this.value);
  final int value;

  static ItemType fromValue(int? raw) {
    if (raw == null) return ItemType.unknown;
    
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    return ItemType.unknown; // ✅ Возвращаем unknown вместо null
  }
}
```

## Примеры использования

### Безопасный парсинг с null

```dart
enum OrderStatus {
  pending(0),
  confirmed(1),
  shipped(2),
  delivered(3);

  const OrderStatus(this.value);
  final int value;

  static OrderStatus? fromValue(int? raw) {
    if (raw == null) return null;
    
    for (final e in OrderStatus.values) {
      if (e.value == raw) return e;
    }
    return null; // ✅ null для неизвестных значений
  }
}

class Order {
  final String id;
  final OrderStatus? status; // nullable для неизвестных статусов

  const Order({required this.id, this.status});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: OrderStatus.fromValue(json['status'] as int?), // ✅ безопасно
    );
  }
}
```

### Обработка неизвестных значений

```dart
class DataProcessor {
  static void processItem(Item item) {
    final type = item.type;
    
    if (type == null) {
      // ✅ Явная обработка неизвестного типа
      print('Warning: Unknown item type, skipping processing');
      return;
    }
    
    switch (type) {
      case ItemType.book:
        print('Processing book...');
        break;
      case ItemType.movie:
        print('Processing movie...');
        break;
      case ItemType.music:
        print('Processing music...');
        break;
    }
  }
}
```

## Проверка правила

### Что проверяется

- [ ] `fromValue()` возвращает `null` для неизвестных значений (по умолчанию)
- [ ] Допускается `unknown` вариант, если логика требует non-null
- [ ] Явная обработка неизвестных значений
- [ ] Отсутствуют исключения при парсинге некорректных данных
- [ ] Код устойчив к некорректным внешним данным

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все enum'ы безопасно обрабатывают неизвестные значения.

## Связанные правила

- [DART-DATA-ENUM](DART-DATA-ENUM.md) - Общие принципы работы с enum
- [DART-DATA-JSON](DART-DATA-JSON.md) - JSON сериализация enum'ов
