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

## Описание правила

При работе с JSON сериализацией enum'ов в Dart необходимо правильно обрабатывать их числовые значения. Это правило обеспечивает типобезопасность и корректную работу с API.

## Основные принципы

1. **Enum должен иметь поле `value`** для хранения числового кода
2. **Метод `fromValue()`** для конвертации числа в enum
3. **В `fromJson`** используем `Enum.fromValue(json['field'] as int?)`
4. **В `toJson`** возвращаем `enum.value` для получения числа

## Плохо

```dart title="docs/examples/bad/bad-json-serde-001.dart"

class BasePaginationRequest {
  const BasePaginationRequest({
    required this.offset,
    required this.filterType, // ❌ тип int?, должен быть enum?
  });

  final int offset;
  final int? filterType; // ❌

  factory BasePaginationRequest.fromJson(Map<String, dynamic> json) {
    return BasePaginationRequest(
      offset: json['Offset'] as int,
      filterType: json['FilterType'] as int?, // ❌ без парсинга в enum
    );
  }

  Map<String, dynamic> toJson() => {
        'Offset': offset,
        'FilterType': filterType?.toString(), // ❌ сериализация в строку
      };
}
```

**Проблемы:**
- `filterType` имеет тип `int?` вместо `FilterType?`
- В `fromJson` нет конвертации числа в enum
- В `toJson` enum конвертируется в строку вместо числа
- Отсутствует типобезопасность

## Хорошо

```dart:docs/examples/good/good-json-serde-001.dart
enum FilterType {
  recent(1),
  popular(2);

  const FilterType(this.value);
  final int value;

  static FilterType? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in FilterType.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}

class BasePaginationRequest {
  const BasePaginationRequest({
    required this.offset,
    required this.filterType,
  });

  final int offset;
  final FilterType? filterType; // ✅ enum в модели

  factory BasePaginationRequest.fromJson(Map<String, dynamic> json) {
    return BasePaginationRequest(
      offset: json['Offset'] as int,
      filterType: FilterType.fromValue(json['FilterType'] as int?) ?? FilterType.recent, // ✅ парсинг через fromValue
    );
  }

  Map<String, dynamic> toJson() => {
        'Offset': offset,
        'FilterType': filterType?.value, // ✅ обратно в число
      };
}
```

**Преимущества:**
- Типобезопасность: `filterType` имеет правильный тип `FilterType?`
- Правильный парсинг: `fromJson` использует `FilterType.fromValue()`
- Корректная сериализация: `toJson` возвращает числовое значение через `.value`
- Enum с методом `fromValue()` для конвертации

## Примеры использования

### Создание enum с числовыми значениями

```dart
enum Status {
  pending(0),
  active(1),
  completed(2),
  cancelled(3);

  const Status(this.value);
  final int value;

  static Status? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in Status.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}
```

### Сериализация в JSON

```dart
class Task {
  final String title;
  final Status status;

  const Task({required this.title, required this.status});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      status: Status.fromValue(json['status'] as int?) ?? Status.pending,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'status': status.value, // ✅ используем .value
      };
}
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
