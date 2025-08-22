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

```dart
--8<-- "docs/examples/bad/bad-strict-ctor-001.dart"
```

**Проблемы:**
- Отсутствует `required` для nullable полей
- Можно случайно забыть передать поля при создании
- Неявность в том, какие поля обязательны
- Возможность создания неполных объектов

## Хорошо

```dart
--8<-- "docs/examples/good/good-strict-ctor-001.dart"
```

**Преимущества:**
- Явность: все поля должны быть явно переданы
- Безопасность: невозможно создать объект с неинициализированными полями
- Читаемость: понятно, какие поля обязательны
- Предотвращение ошибок: компилятор требует передачи всех полей

## Примеры использования

### Строгий конструктор для nullable полей

```dart
--8<-- "docs/examples/good/good-strict-ctor-002.dart"
```

### Строгий конструктор для enum полей

```dart
--8<-- "docs/examples/good/good-strict-ctor-003.dart"
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
