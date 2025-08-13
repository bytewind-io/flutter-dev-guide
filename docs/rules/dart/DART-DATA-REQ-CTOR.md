---
id: DART-DATA-REQ-CTOR
title: "Строгий конструктор: required для всех полей (включая nullable)"
status: stable
severity: error
category: dart/data-class
tags: [constructor, required, null-safety]
linter_rule:
coverage: ai
bad_snippet: bad-strict-ctor-001.dart
good_snippet: good-strict-ctor-001.dart
references:
  - https://dart.dev/guides/language/effective-dart/style
ai_hint: >
  Ensure all final fields have required named parameters in constructor.
  Nullable fields keep nullable types but still require explicit null when creating an object.
---

## Пояснение

Во всех data-классах следует делать все параметры конструктора `required`, даже если их тип nullable. Это обеспечивает явность в коде и предотвращает случайное создание объектов с неинициализированными полями.

## Основные принципы

1. **Все параметры конструктора должны быть `required`** для final полей
2. **Nullable поля остаются nullable**, но требуют явной передачи `null`
3. **Явность создания** объекта со всеми полями
4. **Предотвращение ошибок** с неинициализированными полями

## Плохо

```dart title="docs/examples/bad/bad-strict-ctor-001.dart"

class User {
  const User({
    this.id, // ❌ отсутствует required
    required this.name,
    this.email, // ❌ отсутствует required
  });

  final String? id;
  final String name;
  final String? email;

  // ❌ Можно случайно забыть передать поля
  static User create(String name) {
    return User(name: name); // id и email будут null
  }
}
```

**Проблемы:**
- Отсутствует `required` для nullable полей
- Можно случайно забыть передать поля при создании
- Неявность в том, какие поля обязательны
- Возможность создания неполных объектов

## Хорошо

```dart:docs/examples/good/good-strict-ctor-001.dart
class User {
  const User({
    required this.id, // ✅ required для nullable поля
    required this.name,
    required this.email, // ✅ required для nullable поля
  });

  final String? id;
  final String name;
  final String? email;

  // ✅ Явно указываем все поля, включая null
  static User create(String name) {
    return User(
      id: null, // ✅ явно передаем null
      name: name,
      email: null, // ✅ явно передаем null
    );
  }

  // ✅ Factory для создания с id
  factory User.withId(String id, String name, String? email) {
    return User(
      id: id,
      name: name,
      email: email,
    );
  }
}
```

**Преимущества:**
- Явность: все поля должны быть явно переданы
- Безопасность: невозможно создать объект с неинициализированными полями
- Читаемость: понятно, какие поля обязательны
- Предотвращение ошибок: компилятор требует передачи всех полей

## Примеры использования

### Строгий конструктор для nullable полей

```dart
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description, // nullable, но required
    required this.price,
    required this.category,
    required this.tags, // nullable, но required
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final ProductCategory category;
  final List<String>? tags;

  // ✅ Явно передаем null для nullable полей
  static Product createBasic(String id, String name, double price, ProductCategory category) {
    return Product(
      id: id,
      name: name,
      description: null, // ✅ явно null
      price: price,
      category: category,
      tags: null, // ✅ явно null
    );
  }
}
```

### Строгий конструктор для enum полей

```dart
class Order {
  const Order({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.shippingAddress, // nullable, но required
  });

  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;
  final Address? shippingAddress;

  // ✅ Factory с явной передачей null
  factory Order.create(String id, List<OrderItem> items, double total) {
    return Order(
      id: id,
      status: OrderStatus.pending,
      items: items,
      total: total,
      shippingAddress: null, // ✅ явно null
    );
  }
}
```

## Проверка правила

### Что проверяется

- [ ] Все final поля имеют `required` параметры в конструкторе
- [ ] Nullable поля остаются nullable, но требуют `required`
- [ ] При создании объектов явно передаются все поля, включая `null`
- [ ] Отсутствуют неинициализированные поля
- [ ] Конструктор явно показывает все необходимые параметры

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все data-классы используют строгие конструкторы с `required` для всех полей.

## Связанные правила

- [DART-DATA-FACTORY](DART-DATA-FACTORY.md) - Factory конструкторы
- [DART-DATA-EQUATABLE](DART-DATA-EQUATABLE.md) - Реализация equals и hashCode
