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

## Пояснение

При парсинге enum'ов из внешних данных (JSON, API) могут встречаться неизвестные значения. По умолчанию следует возвращать `null`, но если логика требует non-null, допускается использование специального `unknown` варианта.

## Основные принципы

1. **По умолчанию возвращаем `null`** для неизвестных значений
2. **Допускается `unknown` вариант**, если логика требует non-null
3. **Явная обработка** неизвестных значений
4. **Robustness** - устойчивость к некорректным данным

## Плохо

```dart
--8<-- "docs/examples/bad/bad-enum-unknown-001.dart"
```

**Проблемы:**
- Исключение при неизвестных значениях
- Приложение может упасть на некорректных данных
- Отсутствует graceful degradation
- Нет явной обработки ошибок

## Хорошо

```dart
--8<-- "docs/examples/good/good-enum-unknown-001.dart"
```

**Преимущества:**
- Безопасность: `null` для неизвестных значений
- Явная обработка: можно решить, что делать с неизвестными данными
- Robustness: приложение не падает на некорректных данных
- Гибкость: можно выбрать стратегию обработки

## Альтернативный подход с unknown

Если логика требует non-null, можно добавить специальный `unknown` вариант:

```dart
--8<-- "docs/examples/good/good-enum-unknown-002.dart"
```

## Примеры использования

### Безопасный парсинг с null

```dart
--8<-- "docs/examples/good/good-enum-unknown-003.dart"
```

### Обработка неизвестных значений

```dart
--8<-- "docs/examples/good/good-enum-unknown-004.dart"
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
