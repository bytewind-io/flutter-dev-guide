# Как писать правила

1 правило = 1 файл. Минимальные блоки:
- краткий заголовок,
- мотивация,
- «Плохо/Хорошо» (с внешними сниппетами),
- `linter_rule` (если покрывается линтером),
- `coverage: lint|ai|manual`.

Используй шаблон из `docs/templates-docs/rule-template.md`.

## Шаблон правила

```markdown
---
id:
title:
status: draft
severity: info           # info | warning | error
category: dart/...
tags: []
linter_rule:
coverage: ai             # lint | ai | manual
bad_snippet:
good_snippet:
references: []
ai_hint: >
  Short guidance for AI about how to detect and auto-fix this rule.
---

## Пояснение
Коротко объясни правило и мотивацию.

## Плохо
```dart
// Пример плохого кода
// Замените на реальный путь к файлу: docs/examples/bad/example.dart
```

## Хорошо
```dart
// Пример хорошего кода
// Замените на реальный путь к файлу: docs/examples/good/example.dart
```

## Замечания
Особые случаи, исключения.
```

## Структура файла

### Метаданные (YAML frontmatter)
- **id**: уникальный идентификатор правила
- **title**: краткое название правила
- **status**: статус (draft, active, deprecated)
- **severity**: уровень важности (info, warning, error)
- **category**: категория правила (например, dart/data, dart/style)
- **tags**: теги для группировки
- **linter_rule**: ссылка на правило линтера, если применимо
- **coverage**: способ проверки (lint, ai, manual)
- **bad_snippet**: путь к примеру плохого кода
- **good_snippet**: путь к примеру хорошего кода
- **references**: ссылки на документацию или источники
- **ai_hint**: подсказка для ИИ по автоматическому исправлению

### Основные разделы
1. **Пояснение** - описание правила и его мотивации
2. **Плохо** - примеры нарушений правила
3. **Хорошо** - примеры правильной реализации
4. **Замечания** - особые случаи и исключения
