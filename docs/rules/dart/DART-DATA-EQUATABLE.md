---
id: DART-DATA-EQUATABLE
title: "Дата‑модели наследуются от Equatable (или EquatableMixin)"
status: stable
severity: error
category: dart/equality
tags: [equatable, value-object, mixin, part]
linter_rule:
coverage: ai
bad_snippet: bad-equatable-part-001.dart
good_snippet: good-equatable-part-001-part.dart
references:
  - https://pub.dev/packages/equatable
ai_hint: >
  Accept either `extends Equatable` or `with EquatableMixin` when a proper `props` is present.
  If the class file starts with `part of`, resolve the owning library file, merge imports
  (check that `equatable.dart` is imported there), then evaluate the class.
  Flag only when neither inheritance nor mixin is used, or `props` is missing/empty.
---

## Пояснение
Дата‑модели должны сравниваться по значению, а не по ссылке. Для этого класс:
- наследуется от `Equatable`, **или** использует `with EquatableMixin`;
- определяет `@override List<Object?> get props`. 

- либо обавляем аннотацию `@immutable`** для обозначения неизменяемости


## Плохо (в part-файле без Equatable)
```dart
--8<-- "docs/examples/bad/bad-equatable-part-001.dart"
```

## Хорошо (library + part)
**Файл библиотеки:**
```dart
--8<-- "docs/examples/good/good-equatable-part-001-lib.dart"
```

**Файл part:**
```dart
--8<-- "docs/examples/good/good-equatable-part-001-part.dart"
```

## Альтернатива: EquatableMixin
```dart
--8<-- "docs/examples/good/good-equatable-mixin-001.dart"
```

## Как избежать ложных срабатываний (part/part of, EquatableMixin)
Если класс лежит в `part`‑файле и начинается с `part of '...';`, импорт `equatable.dart` находится в **основном** файле библиотеки.
Проверки «по одиночному файлу» не видят этот импорт и ошибочно флагят нарушение.

### Требования к коду
- Допустимы оба варианта: `extends Equatable` **или** `with EquatableMixin` (при наличии корректного `props`).
- Для `part`‑файлов:
  - в **основном** файле: `import 'package:equatable/equatable.dart';` и `part '<имя part-файла>.dart';`;
  - в `part`‑файле: только `part of '...';` и код класса (без дублей импортов).

### Рекомендации для линтера/скрипта
1. Если файл начинается с `part of`, найди **основной** файл библиотеки (по `part '<этот_файл.dart>'`).
2. Объедини импорты основного файла с AST всех `part`‑файлов и только после этого оценивай наследование/миксины.
3. Считай корректными оба варианта: `extends Equatable` и `with EquatableMixin`.
4. Разрешай локальное подавление в крайних случаях:
   ```dart
   // ignore: DART-DATA-EQUATABLE
   ```
   (только с обоснованием в PR).
