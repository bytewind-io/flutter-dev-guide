---
id: FL-UI-CONDITIONAL-RENDER
title: "Используй условный рендеринг вместо передачи параметра видимости"
status: stable
severity: warning
category: flutter/widgets
tags:
  - widgets
  - ui
  - performance
  - conditional-rendering
  - best-practices
version: 1
owners:
  - "@team-ui"
  - "@team-frontend"

scope:
  include_paths:
    - "lib/**"
  exclude_paths:
    - "test/**"
    - "integration_test/**"
    - "tool/**"

detect:
  patterns:
    - id: visibility_parameter_in_widget
      description: "Виджет принимает параметр для контроля видимости (isVisible, show, display и т.д.)"
      regex: "class\\s+\\w+\\s+extends\\s+(?:StatelessWidget|StatefulWidget)[\\s\\S]*?(?:final\\s+)?bool\\s+(?:isVisible|show|display|shouldShow|isShown|visible)"
      flags: "gm"

message: >
  Не передавай параметр видимости внутрь виджета (isVisible, show и т.д.).
  Вместо этого используй условный рендеринг (if) на уровне родителя для контроля
  отображения виджета. Это улучшает производительность и упрощает код.

autofix:
  suggestion_builder: minimal
  suggestion: >
    Удали параметр видимости из конструктора виджета и используй условный рендеринг
    в родительском виджете: if (isVisible) MyWidget()

linter_rule:
  coverage: ai

ai_hint: >
  1) Проверяй виджеты (классы, наследующие StatelessWidget или StatefulWidget).
  2) Нарушение: виджет принимает boolean параметр для контроля видимости (isVisible, show, display, shouldShow, isShown, visible).
  3) Нарушение: виджет использует внутри себя Visibility, Offstage или Opacity с параметром видимости для скрытия всего содержимого виджета.
  4) НЕ флагируй: параметры enabled, disabled, isEnabled (это не о видимости).
  5) НЕ флагируй: Visibility/Offstage для частичного скрытия одного из нескольких дочерних элементов внутри виджета.
  6) НЕ флагируй: AnimatedOpacity для анимации появления/исчезания.
  7) Правильный подход: условный рендеринг в родителе — if (condition) Widget() вместо Widget(isVisible: condition).
  8) Фокусируйся на случаях, когда виджет создается, но сразу же скрывается через параметр.

bad_snippet: docs/examples/bad/bad-conditional-render-001.dart
good_snippet: docs/examples/good/good-conditional-render-001.dart
references:
  - "Flutter Performance Best Practices: https://docs.flutter.dev/perf/best-practices"
  - "Conditional Widget Rendering: https://dart.dev/language/branches#if"

tests:
  should_flag:
    - path: "lib/ui/widgets/message_banner.dart"
      content: |
        import 'package:flutter/material.dart';

        // ❌ Плохо: виджет принимает параметр видимости
        class MessageBanner extends StatelessWidget {
          final String message;
          final bool isVisible;

          const MessageBanner({
            required this.message,
            required this.isVisible,
          });

          @override
          Widget build(BuildContext context) {
            if (!isVisible) return SizedBox.shrink();

            return Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              child: Text(message),
            );
          }
        }

    - path: "lib/ui/widgets/info_card.dart"
      content: |
        import 'package:flutter/material.dart';

        // ❌ Плохо: виджет использует Visibility с параметром
        class InfoCard extends StatelessWidget {
          final String title;
          final bool show;

          const InfoCard({
            required this.title,
            required this.show,
          });

          @override
          Widget build(BuildContext context) {
            return Visibility(
              visible: show,
              child: Card(
                child: Text(title),
              ),
            );
          }
        }

  should_pass:
    - path: "lib/ui/pages/home_page.dart"
      content: |
        import 'package:flutter/material.dart';

        // ✅ Хорошо: условный рендеринг в родителе
        class HomePage extends StatelessWidget {
          final bool showBanner;
          final String message;

          const HomePage({
            required this.showBanner,
            required this.message,
          });

          @override
          Widget build(BuildContext context) {
            return Column(
              children: [
                Text('Home Page'),
                if (showBanner) MessageBanner(message: message),
              ],
            );
          }
        }

        class MessageBanner extends StatelessWidget {
          final String message;

          const MessageBanner({required this.message});

          @override
          Widget build(BuildContext context) {
            return Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              child: Text(message),
            );
          }
        }

    - path: "lib/ui/widgets/button.dart"
      content: |
        import 'package:flutter/material.dart';

        // ✅ Хорошо: enabled/disabled - это не про видимость
        class CustomButton extends StatelessWidget {
          final String label;
          final bool isEnabled;
          final VoidCallback? onPressed;

          const CustomButton({
            required this.label,
            this.isEnabled = true,
            this.onPressed,
          });

          @override
          Widget build(BuildContext context) {
            return ElevatedButton(
              onPressed: isEnabled ? onPressed : null,
              child: Text(label),
            );
          }
        }

---

## Пояснение

Когда ты создаешь виджет и передаешь в него параметр `isVisible` (или `show`, `display` и т.д.) для контроля его видимости, ты фактически создаешь экземпляр виджета, который затем сразу же скрываешь. Это неэффективно и усложняет код.

**Проблемы такого подхода:**
1. **Лишние вычисления**: Виджет создается и инициализируется, даже если он не будет показан
2. **Лишние объекты в памяти**: Flutter создает объект виджета и элементы дерева виджетов
3. **Усложнение API**: Виджет получает дополнительную ответственность за свою видимость
4. **Менее читаемый код**: Логика видимости размазана между родителем и дочерним виджетом

## Плохо

```dart
// ❌ Виджет принимает параметр видимости
class ErrorMessage extends StatelessWidget {
  final String message;
  final bool isVisible;

  const ErrorMessage({
    required this.message,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    // Виджет создан, но скрыт
    if (!isVisible) return SizedBox.shrink();

    return Container(
      color: Colors.red,
      padding: EdgeInsets.all(16),
      child: Text(message),
    );
  }
}

// Использование
class LoginForm extends StatelessWidget {
  final bool hasError;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(),
        // ❌ Виджет создается всегда, даже когда hasError = false
        ErrorMessage(
          message: errorText,
          isVisible: hasError,
        ),
        ElevatedButton(child: Text('Login')),
      ],
    );
  }
}
```

**Альтернативный плохой пример с Visibility:**

```dart
// ❌ Виджет использует Visibility с параметром
class NotificationBanner extends StatelessWidget {
  final String text;
  final bool show;

  const NotificationBanner({
    required this.text,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Container(
        color: Colors.orange,
        child: Text(text),
      ),
    );
  }
}
```

## Хорошо

```dart
// ✅ Виджет НЕ знает о логике своей видимости
class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.all(16),
      child: Text(message),
    );
  }
}

// Использование с условным рендерингом
class LoginForm extends StatelessWidget {
  final bool hasError;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(),
        // ✅ Виджет создается ТОЛЬКО когда hasError = true
        if (hasError)
          ErrorMessage(message: errorText),
        ElevatedButton(child: Text('Login')),
      ],
    );
  }
}
```

**Альтернативная форма с тернарным оператором:**

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      TextField(),
      // ✅ Также допустимо для компактности
      hasError
        ? ErrorMessage(message: errorText)
        : SizedBox.shrink(), // или const SizedBox()
      ElevatedButton(child: Text('Login')),
    ],
  );
}
```

## Преимущества условного рендеринга

1. **Производительность**: Виджет не создается, если условие ложно
2. **Память**: Нет лишних объектов в памяти
3. **Простота**: Виджет имеет единственную ответственность — отображение контента
4. **Читаемость**: Логика видимости находится в одном месте (у родителя)

## Когда можно использовать Visibility/Offstage

Виджеты `Visibility` и `Offstage` имеют свои законные применения:

### ✅ Допустимо: Частичное скрытие

```dart
// ✅ Виджет скрывает ЧАСТЬ своего содержимого
class UserProfile extends StatelessWidget {
  final User user;
  final bool showEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(user.name),
        Text(user.phone),
        // Скрываем только один элемент из нескольких
        if (showEmail) Text(user.email),
      ],
    );
  }
}
```

### ✅ Допустимо: Анимации появления/исчезания

```dart
// ✅ AnimatedOpacity для плавной анимации
class FadingBanner extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: child,
    );
  }
}
```

### ✅ Допустимо: Сохранение состояния

```dart
// ✅ Offstage для сохранения состояния при скрытии
class TabContent extends StatelessWidget {
  final int currentTab;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Offstage(
          offstage: currentTab != 0,
          child: ExpensiveWidget1(), // Состояние сохраняется
        ),
        Offstage(
          offstage: currentTab != 1,
          child: ExpensiveWidget2(), // Состояние сохраняется
        ),
      ],
    );
  }
}
```

## Исключения

### Параметры enabled/disabled

```dart
// ✅ Параметры enabled/disabled НЕ относятся к видимости
class CustomButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const CustomButton({
    required this.label,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      child: Text(label),
    );
  }
}
```

## Проверка

- [ ] Виджеты не принимают параметры видимости (isVisible, show, display)
- [ ] Условный рендеринг используется на уровне родителя
- [ ] Visibility/Offstage используются только для частичного скрытия или анимаций
- [ ] Параметры enabled/disabled используются по назначению (не для видимости)
