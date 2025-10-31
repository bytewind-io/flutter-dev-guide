---
id: PERF-COLLECTIONS-IDENTICAL
title: "Используйте identical() вместо listEquals/DeepCollectionEquality"
status: stable
severity: warning
category: dart/performance
tags: [performance, collections, comparison, shouldRepaint, lifecycle]
version: 1
owners: ["@team-performance"]
bad_snippet: bad-collection-compare-001.dart
good_snippet: good-collection-identical-001.dart
references:
  - https://docs.flutter.dev/perf/best-practices
  - https://api.dart.dev/stable/dart-core/identical.html
linter_rule:
  coverage: ai
ai_hint: >
  Flag usage of listEquals, setEquals, mapEquals, DeepCollectionEquality().equals
  in performance-critical contexts: shouldRepaint, shouldRelayout, shouldRebuild, 
  updateShouldNotify, didUpdateWidget, Stream.distinct().
  These perform O(n) or O(n*m) comparisons on every frame/rebuild.
  Suggest using identical() for O(1) reference comparison instead.
  Explain that identical checks if two references point to the same object in memory.
  Do not flag: equality checks for primitives, small fixed-size collections (<5 elements),
  or one-time initialization code.
---

## Пояснение

Функции `listEquals()`, `DeepCollectionEquality().equals()` и подобные выполняют **глубокое сравнение** всех элементов коллекции - это операция O(n) или O(n*m).

Когда такое сравнение происходит в **lifecycle методах** (`shouldRepaint`, `didUpdateWidget`) или в **потоках данных** (`Stream.distinct()`), это случается **на каждом кадре** (60 FPS) или при каждом rebuild.

**Решение:** Используйте `identical()` для O(1) проверки ссылки на объект.

## Почему это критично

- `listEquals` перебирает **каждый** элемент - O(n)
- `DeepCollectionEquality` перебирает **рекурсивно** - O(n*m)
- Происходит на **каждом кадре** (60 раз в секунду)
- Создает временные объекты → давление на GC
- "Изнасилование процессора и оперативки" (цитата из документа)

## ❌ Плохо: listEquals в shouldRepaint

```dart
--8<-- "docs/examples/bad/bad-collection-compare-001.dart"
```

**Проблема:**
- O(n) сравнение на каждом кадре анимации
- Для списка из 1000 элементов - 1000 сравнений
- При 60 FPS = 60000 сравнений в секунду!

## ✅ Хорошо: identical() для O(1) проверки

```dart
--8<-- "docs/examples/good/good-collection-identical-001.dart"
```

**Преимущества:**
- `identical()` проверяет только ссылку на объект
- O(1) - одна инструкция процессора
- Никаких аллокаций памяти
- Мгновенно даже для огромных списков

## Как работает identical()

```dart
final list1 = [1, 2, 3];
final list2 = [1, 2, 3];
final list3 = list1;

print(identical(list1, list2)); // false - разные объекты
print(identical(list1, list3)); // true - та же ссылка

print(listEquals(list1, list2)); // true - одинаковое содержимое
```

`identical()` проверяет, указывают ли две переменные на **один и тот же объект в памяти**.

## Стратегии сравнения

### Пессимистичный подход (рекомендуется)

Всегда перерисовываем при разных ссылках:

```dart
@override
bool shouldRepaint(MyPainter old) {
  return !identical(old.data, data);
}
```

### Оптимистичный подход

Быстрая проверка длины сначала:

```dart
@override
bool shouldRepaint(MyPainter old) {
  // Сначала проверяем длину (тоже O(1))
  return old.data.length != data.length ||
         !identical(old.data, data);
}
```

## Где использовать

### ✅ Обязательно в hot path:

- `shouldRepaint` в CustomPainter
- `shouldRelayout` в RenderObject
- `shouldRebuild` в InheritedWidget
- `updateShouldNotify` в Providers
- `didUpdateWidget` проверки
- `Stream.distinct()` для коллекций

### Примеры

```dart
// ❌ ПЛОХО
Stream<List<int>> getIds() {
  return stream.distinct(
    const DeepCollectionEquality().equals, // O(n) на каждое событие!
  );
}

// ✅ ХОРОШО
Stream<List<int>> getIds() {
  return stream.distinct((a, b) => identical(a, b)); // O(1)
}
```

```dart
// ❌ ПЛОХО
@override
bool shouldRelayout(MyLayout oldDelegate) {
  return !const DeepCollectionEquality().equals(
    oldDelegate.items,
    items,
  );
}

// ✅ ХОРОШО
@override
bool shouldRelayout(MyLayout oldDelegate) {
  return !identical(oldDelegate.items, items);
}
```

## Важное замечание о неизменяемости

Для правильной работы `identical()` важно **не мутировать** коллекции:

```dart
// ❌ ПЛОХО - мутация
final list = [1, 2, 3];
list.add(4); // Ссылка не изменилась!

// ✅ ХОРОШО - создаем новый список
final list = [1, 2, 3];
final newList = [...list, 4]; // Новая ссылка
```

При использовании state management (BLoC, Provider, Riverpod) убедитесь, что новое состояние = новый объект.

## Исключения

### Когда можно использовать глубокое сравнение:

- ✅ Очень маленькие коллекции (<5 элементов)
- ✅ Одноразовые проверки (не в hot path)
- ✅ Инициализация виджетов
- ✅ Обработка событий пользователя (не на каждом кадре)

### Когда глубокое сравнение допустимо:

```dart
@override
void initState() {
  super.initState();
  // ✅ Один раз при инициализации - OK
  if (listEquals(widget.items, defaultItems)) {
    _items = defaultItems;
  }
}
```

## Checklist

- [ ] Нет `listEquals` в `shouldRepaint` / `shouldRelayout` / `shouldRebuild`
- [ ] Нет `DeepCollectionEquality` в lifecycle методах
- [ ] `Stream.distinct()` использует `identical()` для коллекций
- [ ] `didUpdateWidget` использует O(1) сравнения
- [ ] Коллекции не мутируются (создаются новые при изменении)

## См. также

- [PERF-CANVAS-BATCH](./PERF-CANVAS-BATCH.md) - batch-методы Canvas
- [DART-DATA-EQUATABLE](../DART-DATA-EQUATABLE.md) - правильное сравнение моделей данных

