---
id: DART-DATA-JSON
title: "fromJson/toJson: enum хранится как .value; парсинг через fromValue"
status: stable
severity: error
category: dart/serialization
tags: [json, serialization, enum]
linter_rule:
coverage: ai
bad_snippet: bad-json-serde-001.dart
good_snippet: good-json-serde-001.dart
references: []
ai_hint: >
  Ensure fromJson converts numeric codes to enum via fromValue, and toJson serializes enum back to its numeric value.
---

## Пояснение

При работе с JSON сериализацией enum'ов в Dart необходимо правильно обрабатывать их числовые значения. Это правило обеспечивает типобезопасность и корректную работу с API.

## Основные принципы

1. **Enum должен иметь поле `value`** для хранения числового кода
2. **Метод `fromValue()`** для конвертации числа в enum
3. **В `fromJson`** используем `Enum.fromValue(json['field'] as int?)`
4. **В `toJson`** возвращаем `enum.value` для получения числа

## Плохо

```dart
--8<-- "docs/examples/bad/bad-json-serde-001.dart"
```

**Проблемы:**
- `filterType` имеет тип `int?` вместо `FilterType?`
- В `fromJson` нет конвертации числа в enum
- В `toJson` enum конвертируется в строку вместо числа
- Отсутствует типобезопасность

## Хорошо

```dart
--8<-- "docs/examples/good/good-json-serde-001.dart"
```

**Преимущества:**
- Типобезопасность: `filterType` имеет правильный тип `FilterType?`
- Правильный парсинг: `fromJson` использует `FilterType.fromValue()`
- Корректная сериализация: `toJson` возвращает числовое значение через `.value`
- Enum с методом `fromValue()` для конвертации

## Примеры использования

### Создание enum с числовыми значениями

```dart
--8<-- "docs/examples/good/good-json-serde-002.dart"
```

### Сериализация в JSON

```dart
--8<-- "docs/examples/good/good-json-serde-003.dart"
```

## Проверка правила

### Что проверяется

- [ ] Enum имеет поле `value` для хранения числового кода
- [ ] Реализован статический метод `fromValue()` для конвертации
- [ ] В `fromJson` используется `Enum.fromValue(json['field'] as int?)`
- [ ] В `toJson` возвращается `enum.value`

### Автоматическая проверка

Это правило проверяется ИИ-агентами при анализе кода. Убедитесь, что все enum'ы, используемые в JSON сериализации, соответствуют данному стандарту.

## Связанные правила

- [DART-DATA-ENUM](DART-DATA-ENUM.md) - Общие принципы работы с enum
- [DART-DATA-FACTORY](DART-DATA-FACTORY.md) - Правила для factory конструкторов
