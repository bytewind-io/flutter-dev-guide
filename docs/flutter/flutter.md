# Стандарты Flutter/Dart

Этот сайт описывает единые правила оформления кода и примеры «хорошо/плохо», пригодные как для людей, так и для ИИ-агентов (проверка PR, подсказки, автоисправления).

## Принципы

- **Doc-as-code**: документация живёт в Git, правится через PR и code-review
- **Человек + ИИ**: структура и форматы удобны для чтения и машинной загрузки (RAG)
- **Порядок проверок в PR**:
  1. Статический линтер (`static_analyze_av`)
  2. Тесты/анализ
  3. ИИ-проверка (запускается только если линтер прошёл)
- **Трассируемость**: каждое правило документа привязано к конкретным проверкам линтера (если такие есть)

## Настройка линтера

### Основная конфигурация
Для использования стандартов в проекте добавьте в `analysis_options.yaml`:

```yaml
include: package:static_analyze_av/analysis_options.yaml
```

### Интеграция с проектом
1. Добавьте зависимость в `pubspec.yaml`:
```yaml
dev_dependencies:
  static_analyze_av: ^latest_version
```

2. Настройте `analysis_options.yaml`:
```yaml
include: package:static_analyze_av/analysis_options.yaml

# Дополнительные настройки проекта
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

3. Запустите проверку:
```bash
dart analyze
```

### GitHub Actions пример
```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: dart analyze
      - run: dart format --set-exit-if-changed .
      - run: flutter test
```

## Работа с JSON и Enum

### Правило: fromJson/toJson с enum.value

При работе с JSON сериализацией enum'ов важно правильно обрабатывать их числовые значения.

#### ❌ Плохой пример

```dart:docs/examples/bad/bad-json-serde-001.dart
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

#### ✅ Хороший пример

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
      filterType: FilterType.fromValue(json['FilterType'] as int?), // ✅ парсинг через fromValue
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

### Ключевые принципы работы с enum в JSON

1. **Enum должен иметь поле `value`** для хранения числового кода
2. **Метод `fromValue()`** для конвертации числа в enum
3. **В `fromJson`** используем `Enum.fromValue(json['field'] as int?)`
4. **В `toJson`** возвращаем `enum.value` для получения числа

## Структура документации

### Правила
Каждое правило хранится в отдельном файле с YAML-frontmatter для метаданных:

- **ID**: уникальный идентификатор правила
- **Категория**: группировка правил (dart/enums, dart/data-class, etc.)
- **Severity**: уровень важности (error, warning, info)
- **Теги**: для поиска и группировки
- **Linter rule**: связь с правилом линтера (если есть)
- **Coverage**: что покрывает проверка (lint|ai|manual)
- **Примеры**: ссылки на good/bad примеры

### Примеры кода
Примеры хранятся в `docs/examples/{good|bad}` как отдельные .dart файлы:
- Включаются в Markdown через `--8<--`
- Видны на странице, но живут как код
- Проверяются в CI

## Быстрый старт

1. Добавь репозиторий стандартов как submodule или subtree
2. Используй шаблон правила из `docs/templates-docs/rule-template.md`
3. Примеры кода кладём в `docs/examples/{good|bad}` и включаем в правило

## Интеграция с проектами

### Git Submodule/Subtree
```bash
# Добавление как submodule
git submodule add <repo-url> docs/standards

# Добавление как subtree
git subtree add --prefix=docs/standards <repo-url> main --squash
```

### CI/CD интеграция
В проектах настраиваем проверки в следующем порядке:
1. Линтер (`static_analyze_av` через `dart analyze`)
2. `dart format/dart test`
3. ИИ-ревью (читает rules_map.json из стандарта)

## AI-интеграция

Для ИИ-агентов (Cursor, Codex и др.) предоставляется машинно-читаемый маппинг правил в `docs/mappings/rules_map.json`.

## Покрытие проверок

- **Lint**: автоматические проверки линтером
- **AI**: проверки ИИ-агентами на основе правил
- **Manual**: ручные проверки в code review

## Ссылки

- [Правила Dart](../rules/dart/)
- [Шаблоны](../templates-docs/)
- [Примеры](../examples/)
- [Маппинг правил](../mappings/)
