---
id: DART-DATA-FACTORY
title: "Используй factory для сценариев с отсутствующими/генерируемыми полями"
status: stable
severity: warning
category: dart/data-class
tags: [factory, constructor]
linter_rule:
coverage: ai
bad_snippet: bad-factory-001.dart
good_snippet: good-factory-001.dart
references: []
ai_hint: >
  Detect repeated creation patterns with missing fields and suggest factory constructor
  that explicitly fills null/defaults and delegates to the strict constructor.
---

## Описание правила

При создании объектов с отсутствующими или генерируемыми полями следует использовать factory конструкторы. Это обеспечивает явность в коде и делегирование к основному строгому конструктору.

## Основные принципы

1. **Используем factory конструктор** для сценариев с отсутствующими полями
2. **Явно указываем `null`/значения по умолчанию** для недостающих полей
3. **Делегируем к основному строгому конструктору**
4. **Избегаем дублирования логики** создания объектов

## Плохо

```dart:docs/examples/bad/bad-factory-001.dart
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  // ❌ Дублирование логики создания
  static User createFromApi(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  // ❌ Еще одно дублирование
  static User createFromForm(String name, String email) {
    return User(
      id: '', // ❌ пустая строка вместо null
      name: name,
      email: email,
    );
  }
}
```

**Проблемы:**
- Дублирование логики создания объектов
- Неявные значения по умолчанию
- Отсутствие делегирования к основному конструктору
- Пустые строки вместо `null` для отсутствующих полей

## Хорошо

```dart:docs/examples/good/good-factory-001.dart
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  // ✅ Factory для создания из API
  factory User.fromApi(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  // ✅ Factory для создания из формы (без id)
  factory User.fromForm(String name, String email) {
    return User(
      id: '', // ✅ явно указываем пустую строку
      name: name,
      email: email,
    );
  }

  // ✅ Factory для создания с генерируемым id
  factory User.create(String name, String email) {
    return User(
      id: _generateId(), // ✅ генерируем id
      name: name,
      email: email,
    );
  }

  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
```

**Преимущества:**
- Явность: каждый factory показывает, какие поля отсутствуют
- Делегирование: все factory используют основной конструктор
- Читаемость: понятно, откуда берутся значения
- Гибкость: разные сценарии создания через отдельные factory

## Примеры использования

### Factory для создания с временными данными

```dart
class Order {
  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime createdAt;

  // ✅ Factory для создания заказа в корзине
  factory Order.fromCart(List<OrderItem> items) {
    return Order(
      id: '', // будет заполнено при сохранении
      items: items,
      total: items.fold(0.0, (sum, item) => sum + item.price),
      createdAt: DateTime.now(),
    );
  }

  // ✅ Factory для создания из JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      total: json['total'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

### Factory с валидацией

```dart
class Product {
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

  // ✅ Factory с валидацией цены
  factory Product.create(String name, double price, ProductCategory category) {
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    
    return Product(
      id: _generateId(),
      name: name,
      price: price,
      category: category,
    );
  }

  static String _generateId() => 'prod_${DateTime.now().millisecondsSinceEpoch}';
}
```

## Проверка правила

### Что проверяется

- [ ] Для сценариев с отсутствующими полями используется factory конструктор
- [ ] Factory явно указывает значения по умолчанию для недостающих полей
- [ ] Все factory делегируют к основному строгому конструктору
- [ ] Отсутствует дублирование логики создания объектов
- [ ] Factory имеют понятные названия, отражающие сценарий создания

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все сценарии создания объектов с отсутствующими полями используют factory конструкторы.

## Связанные правила

- [DART-DATA-REQ-CTOR](DART-DATA-REQ-CTOR.md) - Строгие конструкторы
- [DART-DATA-JSON](DART-DATA-JSON.md) - JSON сериализация
