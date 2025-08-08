---
id: DART-DATA-EQUATABLE
title: "Дата‑модели наследуются от Equatable"
status: stable
severity: error
category: dart/equality
tags: [equatable, value-object]
linter_rule:
coverage: ai
bad_snippet: bad-equatable-001.dart
good_snippet: good-equatable-001.dart
references:
  - https://pub.dev/packages/equatable
ai_hint: >
  Data models should extend Equatable and list all significant fields in props to ensure value equality.
---

## Описание правила

Data-модели должны наследоваться от `Equatable` и переопределять равенство по полям. Это обеспечивает корректную работу в коллекциях, кешах, тестах и предотвращает ошибки сравнения объектов.

## Основные принципы

1. **Data-модели наследуются от `Equatable`**
2. **Переопределяем `props`** со всеми значимыми полями
3. **Исключаем поля**, которые не влияют на равенство (например, временные метки)
4. **Обеспечиваем value equality** вместо reference equality

## Плохо

```dart:docs/examples/bad/bad-equatable-001.dart
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  // ❌ Отсутствует Equatable
  // ❌ Нет переопределения равенства
  // ❌ Сравнение по ссылке, а не по значению
}
```

**Проблемы:**
- Отсутствует наследование от `Equatable`
- Нет переопределения равенства по полям
- Сравнение объектов происходит по ссылке
- Неправильная работа в коллекциях и кешах

## Хорошо

```dart:docs/examples/good/good-equatable-001.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        // createdAt не включаем, так как это временная метка
      ];

  // ✅ Равенство по значимым полям
  // ✅ Корректная работа в коллекциях
  // ✅ Правильное сравнение в тестах
}
```

**Преимущества:**
- Value equality: объекты равны по содержимому, а не по ссылке
- Корректная работа в `Set`, `Map`, `List`
- Правильное сравнение в тестах
- Исключение временных полей из сравнения

## Примеры использования

### Базовый Equatable для простой модели

```dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  final String id;
  final String name;
  final double price;
  final ProductCategory category;

  @override
  List<Object?> get props => [id, name, price, category];
}
```

### Equatable с исключением временных полей

```dart
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        items,
        total,
        status,
        // createdAt и updatedAt не включаем - это метаданные
      ];
}
```

### Equatable для сложных объектов

```dart
import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
  });

  final String street;
  final String city;
  final String country;
  final String postalCode;

  @override
  List<Object?> get props => [street, city, country, postalCode];
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final Address address;

  @override
  List<Object?> get props => [id, name, address]; // address тоже Equatable
}
```

## Проверка правила

### Что проверяется

- [ ] Data-модели наследуются от `Equatable`
- [ ] Переопределен метод `props` со всеми значимыми полями
- [ ] Исключены поля, не влияющие на равенство (временные метки, счетчики)
- [ ] Корректно работает сравнение объектов
- [ ] Правильно работает в коллекциях (`Set`, `Map`, `List`)

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все data-модели используют `Equatable` для корректного сравнения.

## Связанные правила

- [DART-DATA-REQ-CTOR](DART-DATA-REQ-CTOR.md) - Строгие конструкторы
- [DART-DATA-FACTORY](DART-DATA-FACTORY.md) - Factory конструкторы
