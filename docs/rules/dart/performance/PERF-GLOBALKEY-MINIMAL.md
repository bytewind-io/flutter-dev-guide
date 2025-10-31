---
id: PERF-GLOBALKEY-MINIMAL
title: "GlobalKey: используйте только для Navigator/Scaffold/Form"
status: stable
severity: warning
category: dart/performance
tags: [performance, globalkey, context, renderbox, architecture]
version: 1
owners: ["@team-performance"]
bad_snippet: bad-globalkey-renderbox-001.dart
good_snippet: good-context-renderbox-001.dart
references:
  - https://docs.flutter.dev/perf/best-practices
  - https://api.flutter.dev/flutter/widgets/GlobalKey-class.html
linter_rule:
  coverage: ai
ai_hint: >
  Flag GlobalKey usage except for Navigator, Scaffold, Form, and AnimatedList.
  GlobalKey is "heavy" - stored in global registry, can cause issues with widget reuse.
  Suggest using context directly (context.findRenderObject), passing context via callbacks,
  or using controllers instead.
  Do not flag: GlobalKey for navigatorKey, scaffoldKey, formKey, AnimatedListKey.
---

## Пояснение

`GlobalKey` - это "тяжелый" объект, который хранится в глобальной таблице и может вызвать проблемы при переиспользовании виджета. 

Чрезмерное использование GlobalKey - часто признак **неправильной архитектуры**.

**Решение:** Используйте `context` напрямую, передавайте через callback или используйте контроллеры.

## Почему это плохо

- GlobalKey хранится в **глобальной таблице** - overhead на память
- Может вызвать проблемы при переиспользовании виджета
- Затрудняет тестирование
- Нарушает принципы композиции виджетов
- Единственное оправданное использование - навигация, Scaffold и Form

## ❌ Плохо: GlobalKey для RenderBox

```dart
--8<-- "docs/examples/bad/bad-globalkey-renderbox-001.dart"
```

**Проблема:**
- GlobalKey не нужен для получения RenderBox
- Лишний объект в глобальной таблице
- Усложняет код без необходимости

## ✅ Хорошо: Контекст напрямую

```dart
--8<-- "docs/examples/good/good-context-renderbox-001.dart"
```

**Преимущества:**
- Нет лишних объектов
- Проще код
- Следуем принципам Flutter

## ✅ Хорошо: Передача через callback

```dart
--8<-- "docs/examples/good/good-context-callback-001.dart"
```

## Оправданное использование GlobalKey

### ✅ Navigator

```dart
class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: HomePage(),
    );
  }
  
  // Для навигации без context
  void navigateToHome() {
    navigatorKey.currentState?.pushReplacementNamed('/home');
  }
}
```

### ✅ Scaffold

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheet() {
    _scaffoldKey.currentState!.showBottomSheet(
      (context) => BottomSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Content(),
    );
  }
}
```

### ✅ Form

```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Обработка данных
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### ✅ AnimatedList

```dart
class MyList extends StatefulWidget {
  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = [];

  void _addItem() {
    final index = _items.length;
    _items.add('Item $index');
    _listKey.currentState!.insertItem(index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      itemBuilder: (context, index, animation) {
        return _buildItem(_items[index], animation);
      },
    );
  }
}
```

## Альтернативы GlobalKey

### 1. Контекст напрямую

Для получения RenderBox или размеров виджета:

```dart
class MyWidget extends StatelessWidget {
  void _handleTap(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final position = box.localToGlobal(Offset.zero);
    
    print('Size: $size, Position: $position');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(),
    );
  }
}
```

### 2. Контроллеры

Для управления виджетами используйте контроллеры:

```dart
class ScreenshotController {
  Future<Uint8List> Function()? _capture;

  Future<Uint8List> capture() async {
    if (_capture == null) {
      throw StateError('Controller not attached');
    }
    return await _capture!();
  }
}

class ScreenshotWidget extends StatefulWidget {
  final ScreenshotController controller;

  const ScreenshotWidget({required this.controller});

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller._capture = _takeScreenshot;
  }

  Future<Uint8List> _takeScreenshot() async {
    final RenderRepaintBoundary boundary =
        context.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: MyContent());
  }
}
```

### 3. Поиск по дереву виджетов

Для поиска RepaintBoundary или других RenderObject:

```dart
static Future<Uint8List> takeScreenshot(BuildContext context) async {
  RenderRepaintBoundary? boundary;
  
  context.visitAncestorElements((element) {
    final renderObject = element.renderObject;
    if (renderObject is RenderRepaintBoundary) {
      boundary = renderObject;
      return false; // Нашли, прекращаем поиск
    }
    return true;
  });

  if (boundary == null) {
    throw UnsupportedError('No RepaintBoundary found');
  }

  final image = await boundary!.toImage();
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
```

## Правило

**Если вы используете GlobalKey не для Navigator, Scaffold, Form или AnimatedList - подумайте дважды!**

В 99% случаев есть лучшее решение:
- Контекст напрямую
- Callback с контекстом
- Контроллеры
- InheritedWidget / Provider

## Checklist

- [ ] GlobalKey используется только для Navigator/Scaffold/Form/AnimatedList
- [ ] Нет GlobalKey для получения RenderBox (используется context)
- [ ] Нет GlobalKey для RepaintBoundary (используется context или контроллер)
- [ ] Виджеты взаимодействуют через callbacks, а не через GlobalKey

## Сравнение подходов

| Подход | Плюсы | Минусы | Когда использовать |
|--------|-------|--------|-------------------|
| GlobalKey | Доступ из любого места | Тяжелый, глобальное состояние | Navigator, Scaffold, Form |
| Context | Легкий, локальный | Нужен context | Большинство случаев |
| Controller | Четкий контракт | Больше кода | Сложные виджеты |
| InheritedWidget | Реактивность | Сложность | Передача данных вниз |

## См. также

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [ARCH-REPO-STATELESS](../architecture/ARCH-REPO-STATELESS.md) - правильная архитектура

