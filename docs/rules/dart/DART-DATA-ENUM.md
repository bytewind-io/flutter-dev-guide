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

## Пояснение

Вместо использования магических чисел для представления дискретных состояний следует использовать enum'ы. Это обеспечивает типобезопасность, читаемость кода и предотвращает ошибки.

## Основные принципы

1. **Заменяем `int` поля на `enum`** для дискретных состояний
2. **Реализуем `static fromValue(int?) -> T?`** для безопасного парсинга
3. **Возвращаем `null`** для неизвестных значений
4. **Используем `enum.value`** для получения числового представления

## Плохо

```dart
--8<-- "docs/examples/bad/bad-enum-parse-001.dart"
```

**Проблемы:**
- `role` имеет тип `int` вместо `UserRole`
- Хардкод магических чисел в геттерах
- Отсутствует валидация значений при парсинге
- Нет типобезопасности

## Хорошо

```dart
--8<-- "docs/examples/good/good-enum-parse-001.dart"
```

**Преимущества:**
- Типобезопасность: `role` имеет тип `UserRole`
- Читаемость: `UserRole.admin` вместо `1`
- Безопасность: `fromValue()` возвращает `null` для неизвестных значений
- Валидация: парсинг через enum с fallback значением

## Примеры использования

### Создание enum с числовыми значениями

```dart
--8<-- "docs/examples/good/good-enum-parse-002.dart"
```

### Использование в модели

```dart
--8<-- "docs/examples/good/good-enum-parse-003.dart"
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
