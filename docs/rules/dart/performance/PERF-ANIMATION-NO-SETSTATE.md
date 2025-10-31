---
id: PERF-ANIMATION-NO-SETSTATE
title: "Анимации: используйте AnimatedBuilder вместо setState"
status: stable
severity: warning
category: dart/performance
tags: [performance, animation, setState, rebuild, AnimatedBuilder]
version: 2
owners: ["@team-performance"]
bad_snippet: bad-animation-setstate-001.dart
good_snippet: good-animation-builder-001.dart
references:
  - https://docs.flutter.dev/perf/best-practices
  - https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
  - https://api.flutter.dev/flutter/rendering/CustomPainter/CustomPainter.html
  - https://api.flutter.dev/flutter/rendering/FlowDelegate/FlowDelegate.html
  - https://api.flutter.dev/flutter/rendering/MultiChildLayoutDelegate/MultiChildLayoutDelegate.html
linter_rule:
  coverage: ai
ai_hint: >
  Flag AnimationController.addListener() with setState() calls inside.
  This causes full widget rebuild on every animation frame (60 FPS).
  Suggest using AnimatedBuilder, specialized transition widgets (RotationTransition, FadeTransition, etc.),
  CustomPaint with repaint parameter, FlowDelegate with repaint, or MultiChildLayoutDelegate with relayout.
  Explain that repaint/relayout skip Build and Element phases, going directly to Paint/Layout.
  Suggest Listenable.merge() when multiple independent sources need to be tracked.
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

## ✅ Listenable.merge() для множественных источников

Когда нужно следить за **несколькими независимыми источниками** изменений (например, анимация + данные):

```dart
--8<-- "docs/examples/good/good-custompaint-merge-001.dart"
```

**Как работает Listenable.merge():**
- Подписывается на **каждый** Listenable в списке
- Нотифицирует при изменении **любого** из них
- Идеально для случаев, когда есть несколько независимых источников

**Когда использовать:**
- ✅ Анимация + изменяемые данные
- ✅ Несколько независимых анимаций
- ✅ Анимация + пользовательский ввод (ValueNotifier)

## 🎯 Фазы рендеринга Flutter

Понимание фаз рендеринга помогает осознать, почему `repaint`/`relayout` так эффективны.

### Полный цикл рендеринга (с setState):

```
1. Build     → Пересоздание Widget tree
2. Element   → Обновление Element tree  
3. Layout    → Вычисление размеров и позиций (RenderObject)
4. Paint     → Создание инструкций отрисовки (Picture)
5. Composite → Отправка в GPU через Skia
```

### Оптимизированный цикл (с repaint):

```
1. Build     → ✅ ПРОПУСКАЕТСЯ
2. Element   → ✅ ПРОПУСКАЕТСЯ  
3. Layout    → ✅ ПРОПУСКАЕТСЯ
4. Paint     → ❌ Только перерисовка
5. Composite → ❌ Отправка в GPU
```

### Как это работает:

**При использовании repaint:**
1. При изменении Listenable помечает RenderObject как "требующий перерисовки"
2. При vsync от Flutter Engine обходит только помеченные RenderObject
3. Собирает Picture (инструкции отрисовки) и отдает рендер-движку
4. Skia отрисовывает шейдерами в GPU

**Преимущество:** Начинаем сразу с фазы Paint, минуя Build/Element/Layout!

### Сравнение с браузером:

Flutter использует похожий механизм на Chrome:

| Flutter | Browser | Что происходит |
|---------|---------|----------------|
| Widget/Element | DOM | Структура UI |
| Layout | Layout | Вычисление геометрии |
| Paint | Paint | Создание инструкций отрисовки |
| Composite | Composite | Сборка слоев |
| Skia → GPU | GPU | Рендеринг |

## ✅ FlowDelegate с repaint

Для сложных трансформаций множества виджетов используйте `FlowDelegate` с параметром `repaint`:

```dart
--8<-- "docs/examples/good/good-flow-repaint-001.dart"
```

**Преимущества FlowDelegate:**
- ✅ Минует фазы Build и Element
- ✅ Выполняет только Layout и Paint
- ✅ Идеально для анимации позиций/трансформаций множества виджетов
- ✅ Более производительно чем Stack с Positioned

**Когда использовать:**
- Анимация позиций множества элементов
- Сложные трансформации (rotation, scale, translate)
- Кастомные layout'ы с анимацией

## ✅ MultiChildLayoutDelegate с relayout

Для анимации layout'а используйте `MultiChildLayoutDelegate`:

```dart
--8<-- "docs/examples/good/good-layout-relayout-001.dart"
```

**Преимущества MultiChildLayoutDelegate:**
- ✅ Минует фазу Build виджетов
- ✅ Выполняет Layout и Paint
- ✅ Идеально для анимации размеров/позиций секций
- ✅ Более гибкий чем Column/Row для кастомных layout'ов

**Когда использовать:**
- Анимация размеров секций UI
- Динамические layout'ы с изменяющимися пропорциями
- Сложная геометрия с зависимостями между элементами

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

### Таблица производительности по фазам рендеринга:

| Подход | Build | Element | Layout | Paint | Производительность |
|--------|-------|---------|--------|-------|-------------------|
| `setState + addListener` | ❌ Да | ❌ Да | ❌ Да | ❌ Да | 💀 Очень плохо |
| `AnimatedBuilder` | ⚠️ Частично | ⚠️ Частично | ⚠️ Частично | ❌ Да | 🟡 Средне |
| Специализированные виджеты | ✅ Нет | ✅ Нет | ✅ Нет | ❌ Да | 🟢 Отлично |
| `CustomPaint + repaint` | ✅ Нет | ✅ Нет | ✅ Нет | ❌ Да | 🟢 Отлично |
| `FlowDelegate + repaint` | ✅ Нет | ✅ Нет | ❌ Да | ❌ Да | 🟢 Отлично |
| `MultiChildLayoutDelegate + relayout` | ✅ Нет | ✅ Нет | ❌ Да | ❌ Да | 🟡 Хорошо |

### Когда что использовать:

| Подход | Когда использовать |
|--------|-------------------|
| `setState + addListener` | ❌ **Никогда** |
| `AnimatedBuilder` | ✅ Универсальное решение для большинства анимаций |
| Специализированные виджеты | ✅ Простые анимации (rotation, fade, scale, slide) |
| `CustomPaint + repaint` | ✅ Кастомная отрисовка, canvas, графики |
| `FlowDelegate + repaint` | ✅ Анимация позиций/трансформаций множества виджетов |
| `MultiChildLayoutDelegate + relayout` | ✅ Анимация размеров/геометрии секций UI |

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
- [ ] Используется `Listenable.merge()` для множественных источников изменений
- [ ] FlowDelegate использует `super(repaint: animation)` вместо setState
- [ ] MultiChildLayoutDelegate использует `super(relayout: animation)` 
- [ ] Анимированные виджеты обернуты в `RepaintBoundary` при необходимости
- [ ] Дочерние виджеты передаются через `child` параметр для переиспользования
- [ ] Понятны фазы рендеринга (Build → Element → Layout → Paint → Composite)

## См. также

- [PERF-COLLECTIONS-IDENTICAL](./PERF-COLLECTIONS-IDENTICAL.md) - эффективное сравнение в shouldRepaint
- [Flutter Animation Best Practices](https://docs.flutter.dev/development/ui/animations/tutorial)

