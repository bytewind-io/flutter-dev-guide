---
id: PERF-CANVAS-BATCH
title: "Canvas: используйте batch-методы вместо циклов с draw*"
status: stable
severity: warning
category: dart/performance
tags: [performance, canvas, gpu, fps, custom-painter, batch-rendering]
version: 1
owners: ["@team-performance"]
bad_snippet: bad-canvas-loop-001.dart
good_snippet: good-canvas-batch-001.dart
references:
  - https://docs.flutter.dev/perf/best-practices
  - https://api.flutter.dev/flutter/dart-ui/Canvas-class.html
linter_rule:
  coverage: ai
ai_hint: >
  Detect for/while loops inside paint() methods of CustomPainter classes that call canvas.draw* methods 
  (drawCircle, drawLine, drawRect, drawArc, drawOval, etc.) more than 5 times.
  Flag if the loop iterates over a collection/range and makes individual draw calls.
  Suggest using batch methods: drawRawPoints for points/circles, drawPath for complex shapes, 
  drawVertices for geometry, or drawRawAtlas for sprites.
  Do not flag if: loop has <5 iterations, different Paint objects are used for each element, 
  or culling logic is present.
---

## Пояснение

Каждый вызов метода `canvas.draw*` (drawCircle, drawLine, drawRect и т.д.) создает **отдельную команду для GPU**. Если вы рисуете 1000 объектов в цикле, это означает 1000 команд GPU, что приводит к критическому падению FPS.

**Решение:** Используйте batch-методы Canvas, которые позволяют отрисовать множество объектов **одной командой GPU**.

## Почему это критично

- **FPS падает до 0** при большом количестве объектов
- Каждый `draw*` это отдельная инструкция для рендер-движка
- Огромная нагрузка на CPU и GPU
- Неэффективное использование графического конвейера

В 20-100 раз медленнее batch-методов!

## ❌ Плохо: Цикл с draw методами

```dart
--8<-- "docs/examples/bad/bad-canvas-loop-001.dart"
```

**Проблема:**
- 1000 итераций = 1000 команд GPU
- FPS падает пропорционально количеству объектов
- Невозможно отрисовать >10000 объектов с приемлемой производительностью

## ✅ Хорошо: Batch-метод drawRawPoints

```dart
--8<-- "docs/examples/good/good-canvas-batch-001.dart"
```

**Преимущества:**
- Одна команда GPU вместо тысяч
- 60 FPS даже на 10000+ точках
- Минимальное давление на CPU/GPU
- Эффективное использование памяти

## ✅ Хорошо: drawPath для сложных фигур

```dart
--8<-- "docs/examples/good/good-canvas-batch-002.dart"
```

## Batch-методы Canvas

### 1. `drawRawPoints` - для точек, линий, кругов

Режимы `PointMode`:
- `PointMode.points` - отдельные точки/круги
- `PointMode.lines` - линии между парами точек (0-1, 2-3, 4-5...)
- `PointMode.polygon` - соединенные линии (0-1-2-3-4...)

```dart
final Float32List coords = Float32List(points.length * 2);
for (int i = 0; i < points.length; i++) {
  coords[i * 2] = points[i].dx;
  coords[i * 2 + 1] = points[i].dy;
}
canvas.drawRawPoints(ui.PointMode.points, coords, paint);
```

### 2. `drawPath` - для сложных фигур

```dart
final Path path = Path();
for (double i = 0; i < 2 * pi; i += step) {
  path.addArc(rect, i, arcLength);
}
canvas.drawPath(path, paint); // Один вызов!
```

### 3. `drawVertices` - для сложной геометрии

```dart
canvas.drawVertices(
  ui.Vertices(
    ui.VertexMode.triangles,
    positions, // Float32List координат
    colors: colors, // Optional
    textureCoordinates: uvs, // Optional
  ),
  ui.BlendMode.srcOver,
  paint,
);
```

### 4. `drawRawAtlas` / `drawAtlas` - для спрайтов

```dart
canvas.drawRawAtlas(
  atlas, // ui.Image
  rstTransforms, // Float32List трансформаций
  rects, // Float32List прямоугольников в атласе
  colors, // Optional тинты
  ui.BlendMode.srcOver,
  null,
  paint,
);
```

## Правило: Думайте трижды над циклами в paint

```dart
// ❌ Если у вас есть цикл с draw* внутри paint - ВЫ ДЕЛАЕТЕ ЧТО-ТО НЕ ТАК!
@override
void paint(Canvas canvas, Size size) {
  for (...) {  // ⚠️ СТОП! Подумайте трижды!
    canvas.drawCircle(...);
  }
}
```

### Исключения (когда цикл допустим):

- ✅ Очень маленькое число итераций (< 5)
- ✅ Разные Paint объекты для каждого элемента (разные цвета/стили)
- ✅ Сложная логика, не переносимая в batch метод

### Но даже тогда:

- Используйте `Path` для группировки
- Кэшируйте результаты в `Picture`
- Применяйте culling (отсечение невидимого)

## Culling - отсечение невидимого

Для больших наборов данных используйте culling, чтобы рисовать только видимые объекты:

```dart
@override
void paint(Canvas canvas, Size size) {
  final visibleRect = Rect.fromLTWH(0, 0, size.width, size.height);

  for (var item in allItems) {
    // Проверяем, попадает ли элемент на экран
    if (!visibleRect.overlaps(item.bounds)) continue;
    
    canvas.drawItem(item);
  }
}
```

Для карт с zoom/pan используйте **QuadTree** или другие пространственные индексы для быстрого поиска видимых элементов.

## Checklist

- [ ] Нет циклов с `drawCircle`, `drawLine`, `drawRect` (более 5 итераций)
- [ ] Используются batch методы: `drawRawPoints`, `drawPath`, `drawVertices`
- [ ] Реализован culling для скроллящихся/зумящихся виджетов
- [ ] `shouldRepaint` сравнивает конкретные параметры эффективно

## См. также

- [PERF-COLLECTIONS-IDENTICAL](./PERF-COLLECTIONS-IDENTICAL.md) - для эффективного сравнения в `shouldRepaint`
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

