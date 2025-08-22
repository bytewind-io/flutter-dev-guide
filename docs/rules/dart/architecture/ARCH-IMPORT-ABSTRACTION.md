---
id: ARCH-IMPORT-ABSTRACTION
title: "Зависим от абстракций: импорт интерфейсов вместо реализаций"
status: stable
severity: error
category: architecture/dependency
tags: [interface, implementation, imports]
linter_rule:
coverage: ai
bad_snippet: bad-import-implementation-001.dart
good_snippet: good-import-abstraction-001.dart
references: []
ai_hint: >
  Flag imports of concrete implementation classes in UI/BLoC layers.
  Suggest importing interfaces or abstractions instead, and inject implementations via constructor or DI.
---

## Пояснение

Высокоуровневые слои должны зависеть от абстракций. Прямой импорт реализаций усложняет тестирование и нарушает инверсию зависимостей.

- UI/BLoC импортируют `*Repository` или `*Service` интерфейс, не `*RepositoryImpl`.
- Конкретная реализация передаётся через конструктор или контейнер зависимостей.

## Плохо (импорт реализации)

```dart
--8<-- "docs/examples/bad/bad-import-implementation-001.dart"
```

## Хорошо (импорт интерфейса)

```dart
--8<-- "docs/examples/good/good-import-abstraction-001.dart"
```
