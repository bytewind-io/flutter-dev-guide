---
id: PERF-ANIMATION-NO-SETSTATE
title: "Анимации: используйте AnimatedBuilder вместо setState"
status: stable
severity: warning
category: dart/performance
tags: [performance, animation, setState, rebuild, AnimatedBuilder]
version: 1
owners: ["@team-performance"]
bad_snippet: bad-animation-setstate-001.dart
good_snippet: good-animation-builder-001.dart
references:
  - https://docs.flutter.dev/perf/best-practices
  - https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
linter_rule:
  coverage: ai
ai_hint: >
  Flag AnimationController.addListener() with setState() calls inside.
  This causes full widget rebuild on every animation frame (60 FPS).
  Suggest using AnimatedBuilder, specialized transition widgets (RotationTransition, FadeTransition, etc.),
  or CustomPaint with repaint parameter.
  Do not flag: setState in user input handlers, one-time animations, or non-animation contexts.
---

## Пояснение

Вызов `setState()` в `addListener()` анимационного контроллера приводит к **полному rebuild** виджета **на каждом кадре анимации** (60 раз в секунду).

Это создает огромную нагрузку на CPU, лишнее давление на GC и может привести к пропускам кадров (jank).

**Решение:** Используйте `AnimatedBuilder`, специализированные виджеты или `CustomPaint` с параметром `repaint`.

## Почему это критично

- `setState()` вызывает **полный rebuild** всего виджета и его детей
- Происходит **60 раз в секунду** (каждый кадр)
- Пересоздаются все дочерние виджеты
- Огромная нагрузка на CPU
- Лишнее давление на GC → пропуски кадров

## ❌ Плохо: setState в addListener

```dart
--8<-- "docs/examples/bad/bad-animation-setstate-001.dart"
```

**Проблема:**
- Весь виджет пересобирается 60 раз в секунду
- Container, Center, Text - всё пересоздается
- Неэффективное использование ресурсов
- Возможны пропуски кадров на сложных UI

## ✅ Хорошо: AnimatedBuilder

```dart
--8<-- "docs/examples/good/good-animation-builder-001.dart"
```

**Преимущества:**
- Пересобирается только Transform.rotate
- Дочерний виджет (Container) создается один раз
- Оптимизировано на уровне фреймворка
- Никаких ненужных rebuilds

## ✅ Еще лучше: Специализированные виджеты

```dart
--8<-- "docs/examples/good/good-animation-transition-001.dart"
```

**Специализированные виджеты:**
- `RotationTransition` - вращение
- `FadeTransition` - прозрачность
- `ScaleTransition` - масштаб
- `SlideTransition` - сдвиг
- `PositionedTransition` - позиционирование
- `SizeTransition` - размер
- `DecoratedBoxTransition` - decoration

Эти виджеты **оптимизированы** и работают без rebuilds.

## ✅ CustomPaint с анимацией

```dart
--8<-- "docs/examples/good/good-animation-custompaint-001.dart"
```

**Почему это лучше:**
- CustomPaint подписывается на Animation напрямую через `super(repaint: ...)`
- Перерисовка происходит без rebuild виджета
- Оптимизировано на уровне фреймворка

## Использование Flow для сложных трансформаций

Для сложных трансформаций множества виджетов используйте `Flow`:

```dart
Flow(
  delegate: RotationFlowDelegate(controller),
  children: [MyWidget()],
)

class RotationFlowDelegate extends FlowDelegate {
  RotationFlowDelegate(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    final angle = animation.value * 2 * pi;
    context.paintChild(
      0,
      transform: Matrix4.rotationZ(angle),
    );
  }

  @override
  bool shouldRepaint(RotationFlowDelegate old) {
    return !identical(old.animation, animation);
  }
}
```

## RepaintBoundary для изоляции

Используйте `RepaintBoundary` для изоляции анимированных частей UI:

```dart
// ❌ ПЛОХО - анимация перерисовывает всё дерево
Column(
  children: [
    ExpensiveWidget(),
    AnimatedWidget(), // Вызывает repaint всей Column!
    AnotherExpensiveWidget(),
  ],
)

// ✅ ХОРОШО - изолируем анимацию
Column(
  children: [
    ExpensiveWidget(),
    RepaintBoundary(
      child: AnimatedWidget(), // Изолирован!
    ),
    AnotherExpensiveWidget(),
  ],
)
```

### Когда использовать RepaintBoundary:

- ✅ Вокруг анимированных виджетов
- ✅ Вокруг CustomPaint
- ✅ Вокруг сложных виджетов, которые редко меняются
- ✅ В списках для изоляции элементов

### Когда НЕ использовать:

- ❌ Везде подряд (есть overhead)
- ❌ На мелких виджетах
- ❌ На виджетах, которые и так часто перерисовываются

## Сравнение подходов

| Подход | Rebuilds | Производительность | Когда использовать |
|--------|----------|-------------------|-------------------|
| `setState + addListener` | ❌ Полный rebuild | Плохо | Никогда |
| `AnimatedBuilder` | ✅ Частичный rebuild | Хорошо | Универсально |
| Специализированные виджеты | ✅ Нет rebuilds | Отлично | Простые анимации |
| `CustomPaint + repaint` | ✅ Только repaint | Отлично | Кастомная отрисовка |
| `Flow` | ✅ Только layout | Отлично | Сложные трансформации |

## Правило работы с AnimationController

```dart
// ❌ НИКОГДА не делайте так:
_controller.addListener(() {
  setState(() {});
});

// ✅ Используйте AnimatedBuilder:
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) => ...,
)

// ✅ Или специализированные виджеты:
RotationTransition(turns: _controller, child: ...)

// ✅ Или CustomPaint с repaint:
CustomPaint(painter: MyPainter(animation: _controller))
class MyPainter extends CustomPainter {
  MyPainter({required this.animation}) : super(repaint: animation);
  final Animation animation;
}
```

## Checklist

- [ ] Нет `addListener(() => setState())` для AnimationController
- [ ] Используется `AnimatedBuilder` или специализированные виджеты
- [ ] CustomPaint получает Animation через `super(repaint: animation)`
- [ ] Анимированные виджеты обернуты в `RepaintBoundary` при необходимости
- [ ] Дочерние виджеты передаются через `child` параметр для переиспользования

## См. также

- [PERF-COLLECTIONS-IDENTICAL](./PERF-COLLECTIONS-IDENTICAL.md) - эффективное сравнение в shouldRepaint
- [Flutter Animation Best Practices](https://docs.flutter.dev/development/ui/animations/tutorial)

