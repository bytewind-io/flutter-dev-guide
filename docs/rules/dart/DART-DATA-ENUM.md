---
id: DART-DATA-ENUM
title: "Enum вместо магических чисел + безопасный fromValue"
status: stable
severity: error
category: dart/enums
tags: [enum, parsing, json]
linter_rule:
coverage: ai
bad_snippet: bad-enum-parse-001.dart
good_snippet: good-enum-parse-001.dart
references: []
ai_hint: >
  Replace int fields representing discrete states with enum.
  Implement fromValue(int?) -> T? that returns null for unknown values.
---

## Описание правила

Вместо использования магических чисел для представления дискретных состояний следует использовать enum'ы. Это обеспечивает типобезопасность, читаемость кода и предотвращает ошибки.

## Основные принципы

1. **Заменяем `int` поля на `enum`** для дискретных состояний
2. **Реализуем `static fromValue(int?) -> T?`** для безопасного парсинга
3. **Возвращаем `null`** для неизвестных значений
4. **Используем `enum.value`** для получения числового представления

## Плохо

```dart title="docs/examples/bad/bad-enum-parse-001.dart"


class User {
  const User({
    required this.name,
    required this.role, // ❌ int вместо enum
  });

  final String name;
  final int role; // ❌ магическое число

  bool get isAdmin => role == 1; // ❌ хардкод числа
  bool get isModerator => role == 2; // ❌ хардкод числа
  bool get isUser => role == 3; // ❌ хардкод числа

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      role: json['role'] as int, // ❌ нет валидации
    );
  }
}
```

**Проблемы:**
- `role` имеет тип `int` вместо `UserRole`
- Хардкод магических чисел в геттерах
- Отсутствует валидация значений при парсинге
- Нет типобезопасности

## Хорошо

```dart:docs/examples/good/good-enum-parse-001.dart
enum UserRole {
  user(1),
  moderator(2),
  admin(3);

  const UserRole(this.value);
  final int value;

  static UserRole? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in UserRole.values) {
      if (e.value == raw) return e;
    }
    return null; // ✅ безопасно для неизвестных значений
  }
}

class User {
  const User({
    required this.name,
    required this.role,
  });

  final String name;
  final UserRole role; // ✅ enum вместо int

  bool get isAdmin => role == UserRole.admin; // ✅ читаемо и безопасно
  bool get isModerator => role == UserRole.moderator;
  bool get isUser => role == UserRole.user;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      role: UserRole.fromValue(json['role'] as int?) ?? UserRole.user, // ✅ безопасный парсинг
    );
  }
}
```

**Преимущества:**
- Типобезопасность: `role` имеет тип `UserRole`
- Читаемость: `UserRole.admin` вместо `1`
- Безопасность: `fromValue()` возвращает `null` для неизвестных значений
- Валидация: парсинг через enum с fallback значением

## Примеры использования

### Создание enum с числовыми значениями

```dart
enum OrderStatus {
  pending(0),
  confirmed(1),
  shipped(2),
  delivered(3),
  cancelled(4);

  const OrderStatus(this.value);
  final int value;

  static OrderStatus? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in OrderStatus.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}
```

### Использование в модели

```dart
class Order {
  final String id;
  final OrderStatus status;

  const Order({required this.id, required this.status});

  bool get isCompleted => status == OrderStatus.delivered;
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: OrderStatus.fromValue(json['status'] as int?) ?? OrderStatus.pending,
    );
  }
}
```

## Проверка правила

### Что проверяется

- [ ] Поля с дискретными состояниями имеют тип `enum` вместо `int`
- [ ] Enum реализует статический метод `fromValue(int?) -> T?`
- [ ] `fromValue()` возвращает `null` для неизвестных значений
- [ ] В коде используются `enum.value` вместо магических чисел
- [ ] Парсинг JSON использует `Enum.fromValue()` с fallback

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все дискретные состояния представлены enum'ами с безопасным парсингом.

## Связанные правила

- [DART-DATA-JSON](DART-DATA-JSON.md) - JSON сериализация enum'ов
- [DART-DATA-FACTORY](DART-DATA-FACTORY.md) - Factory конструкторы для парсинга
