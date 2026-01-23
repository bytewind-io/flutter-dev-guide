---
id: FL-UI-ICON-IMAGE-FORMAT
title: "Обязательные правила использования иконок и изображений"
status: stable
severity: error
category: flutter/ui
tags:
  - icons
  - images
  - assets
  - format
  - webp
  - font-icons
  - svg
version: 1
owners:
  - "@team-ui"
  - "@team-frontend"

scope:
  include_paths:
    - "lib/**"
    - "assets/**"
    - "pubspec.yaml"
  exclude_paths:
    - "test/**"
    - "integration_test/**"

detect:
  patterns:
    - id: svg_as_icon
      description: "Использование SVG в качестве иконки"
      regex: "(?:Icon|IconButton|Image\\.asset)\\s*\\([^)]*\\.svg"
      flags: "gm"

    - id: png_image_usage
      description: "Использование PNG для изображений"
      regex: "Image\\.(?:asset|network|file|memory)\\s*\\([^)]*\\.png"
      flags: "gm"

    - id: raster_icon_no_font
      description: "Растровая иконка вместо шрифтовой"
      regex: "IconButton\\s*\\([^)]*Image\\.asset\\s*\\([^)]*\\.(png|jpg|jpeg|webp)"
      flags: "gm"

message: >
  Нарушение правил использования иконок или изображений в приложении.
  Используйте шрифтовые иконки, формат WebP для изображений, и следуйте
  установленным ограничениям на форматы файлов.

autofix:
  suggestion_builder: minimal
  suggestion: >
    Для иконок используйте IconData из шрифтовых иконок (Icons.*, кастомные шрифты).
    Для изображений используйте формат WebP вместо PNG.
    SVG запрещен для иконок, допустим только для изображений в особых случаях.

linter_rule:
  coverage: ai

ai_hint: >
  1) Проверяй использование иконок и изображений в UI-коде.
  2) НАРУШЕНИЯ:
     - SVG файлы используются как иконки (в Icon, IconButton)
     - Растровые изображения (png, jpg) используются как иконки вместо шрифтовых
     - PNG формат для обычных изображений (должен быть WebP)
     - SVG для изображений без явного обоснования
  3) НЕ ФЛАГИРУЙ:
     - Icons.* (Material Icons) и другие шрифтовые иконки
     - Кастомные иконочные шрифты (IconData)
     - WebP изображения
     - Цветные растровые иконки в формате WebP с правильной структурой масштабов
  4) ОСОБЫЕ СЛУЧАИ:
     - SVG допустим для изображений, если есть комментарий с обоснованием
     - Цветные иконки могут быть растровыми (WebP)
  5) Проверяй также наличие версий 1x/2x/3x для растровых иконок.

bad_snippet: docs/examples/bad/bad-icon-image-format-001.dart
good_snippet: docs/examples/good/good-icon-image-format-001.dart
references:
  - "Flutter Icons documentation: https://docs.flutter.dev/ui/widgets/assets#displaying-icons"
  - "WebP format: https://developers.google.com/speed/webp"
  - "Related rule: FL-ASSETS-ICON-DENSITY"

tests:
  should_flag:
    - path: "lib/ui/home_page.dart"
      content: |
        import 'package:flutter/material.dart';
        import 'package:flutter_svg/flutter_svg.dart';

        class HomePage extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    // ❌ SVG как иконка
                    icon: SvgPicture.asset('assets/icons/settings.svg'),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  // ❌ PNG изображение
                  Image.asset('assets/images/banner.png'),
                  // ❌ Растровая иконка вместо шрифтовой
                  IconButton(
                    icon: Image.asset('assets/icons/home.png'),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }
        }

  should_pass:
    - path: "lib/ui/home_page.dart"
      content: |
        import 'package:flutter/material.dart';

        class HomePage extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                actions: [
                  // ✅ Шрифтовая иконка
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  // ✅ WebP изображение
                  Image.asset('assets/images/banner.webp'),
                  // ✅ Шрифтовая иконка
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {},
                  ),
                  // ✅ Цветная растровая иконка в WebP
                  Image.asset(
                    'assets/icons/colored_icon.webp',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            );
          }
        }

---

## Пояснение

Данное правило определяет обязательные рекомендации и запреты на использование иконок и изображений в приложении. Соблюдение этих правил обеспечивает оптимальную производительность, качество отображения и единообразие UI.

## 1. Иконки

### Обязательное использование шрифтовых иконок

**Правило**: Для иконок обязательно должны использоваться шрифтовые иконки (включая кастомные иконочные шрифты).

**Причины**:
- Масштабируются без потери качества
- Малый размер файла
- Простое изменение цвета через `color` параметр
- Не требуют версий для разных плотностей экрана
- Быстрая отрисовка

### Исключение: цветные иконки

**Единственное исключение** — цветные иконки, которые не могут быть представлены одноцветным шрифтом.

В этом случае:
- Допускается использование **растровых изображений**
- **Обязательный формат**: WebP
- Необходимо предоставить версии для всех плотностей экрана (см. [FL-ASSETS-ICON-DENSITY](FL-ASSETS-ICON-DENSITY.md))

### SVG запрещен для иконок

**Запрещено**: Использование формата SVG в качестве иконок.

**Причины запрета**:
- Медленная отрисовка (парсинг XML)
- Большой размер файла по сравнению со шрифтами
- Дополнительная зависимость (flutter_svg)
- Повышенное использование памяти
- Проблемы с производительностью при множественном использовании

## 2. Изображения

### WebP вместо PNG

**Правило**: Формат PNG не рекомендуется использовать для изображений в приложении.

**Предпочтительный формат**: WebP

**Преимущества WebP**:
- На 25-35% меньший размер файла при том же качестве
- Поддержка прозрачности (как PNG)
- Поддержка анимации (как GIF)
- Нативная поддержка во Flutter
- Faster decoding

### SVG для изображений — исключительные случаи

**Правило**: Формат SVG может применяться только в исключительных случаях и только как изображение.

**Допустимые случаи использования SVG**:
1. Требуется **динамическое изменение цвета** элементов изображения
2. Необходимо выполнять **дополнительные действия** с изображением (анимация, трансформации)
3. Изображение содержит **сложную векторную графику**, которая должна масштабироваться бесконечно

**Требование**: При использовании SVG необходимо добавить комментарий с обоснованием выбора формата.

## 3. Масштабирование растровых иконок

Для корректного отображения растровых иконок на устройствах с разной плотностью пикселей обязательно предоставлять иконки в нескольких масштабах.

См. полное описание в правиле **[FL-ASSETS-ICON-DENSITY](FL-ASSETS-ICON-DENSITY.md)**.

**Требуемые версии**:
- **1x** — базовый размер
- **2x** — для экранов с высокой плотностью
- **3x** — для экранов с очень высокой плотностью
- **4x** — при необходимости, для экстремально высокой плотности

**Структура ассетов**:
```
assets/
  icons/
    colored_icon.webp        # 1x (24x24)
    2.0x/
      colored_icon.webp      # 2x (48x48)
    3.0x/
      colored_icon.webp      # 3x (72x72)
    4.0x/
      colored_icon.webp      # 4x (96x96)
```

Flutter автоматически выбирает подходящую версию иконки в зависимости от плотности экрана устройства.

## Плохо

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bad Example'),
        actions: [
          // ❌ SVG используется как иконка
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          // ❌ PNG иконка вместо шрифтовой
          IconButton(
            icon: Image.asset(
              'assets/icons/search.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ❌ PNG для изображения (должен быть WebP)
          Image.asset('assets/images/banner.png'),

          // ❌ SVG для изображения без обоснования
          SvgPicture.asset('assets/images/logo.svg'),

          // ❌ Растровая иконка без версий для разных плотностей
          Row(
            children: [
              Image.asset(
                'assets/icons/home.png',
                width: 24,
                height: 24,
              ),
              Image.asset(
                'assets/icons/profile.png',
                width: 24,
                height: 24,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ❌ JPG иконка вместо шрифтовой
        child: Image.asset('assets/icons/add.jpg'),
        onPressed: () {},
      ),
    );
  }
}
```

**Проблемы**:
1. SVG используется для иконок → медленная отрисовка
2. PNG используется для изображений → большой размер
3. Растровые иконки вместо шрифтовых → нет масштабируемости
4. Нет версий для разных плотностей → размытие на Retina

## Хорошо

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoodExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Example'),
        actions: [
          // ✅ Шрифтовая иконка из Material Icons
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          // ✅ Шрифтовая иконка из Material Icons
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ WebP для изображения
          Image.asset('assets/images/banner.webp'),

          // ✅ SVG для изображения с обоснованием
          // Используется SVG для динамического изменения цвета логотипа
          SvgPicture.asset(
            'assets/images/logo.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).primaryColor,
              BlendMode.srcIn,
            ),
          ),

          // ✅ Шрифтовые иконки
          Row(
            children: [
              Icon(Icons.home, size: 24),
              Icon(Icons.person, size: 24),
            ],
          ),

          // ✅ Цветная растровая иконка в WebP с версиями для разных плотностей
          Image.asset(
            'assets/icons/colored_badge.webp',
            width: 32,
            height: 32,
          ),
          // Структура:
          // assets/icons/colored_badge.webp (1x: 32x32)
          // assets/icons/2.0x/colored_badge.webp (2x: 64x64)
          // assets/icons/3.0x/colored_badge.webp (3x: 96x96)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ✅ Шрифтовая иконка
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

// ✅ Кастомный иконочный шрифт
class CustomIcons {
  static const IconData customIcon = IconData(
    0xe900,
    fontFamily: 'CustomIcons',
  );
}

class CustomIconExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      // ✅ Использование кастомного шрифтового иконочного набора
      icon: Icon(CustomIcons.customIcon),
      onPressed: () {},
    );
  }
}
```

## Создание кастомного иконочного шрифта

Для создания кастомных шрифтовых иконок используйте:
- [FlutterIcon](https://fluttericon.com/) — конвертация SVG в иконочный шрифт
- [IcoMoon](https://icomoon.io/) — создание кастомных шрифтов
- [Fontello](https://fontello.com/) — генератор иконочных шрифтов

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: CustomIcons
      fonts:
        - asset: assets/fonts/CustomIcons.ttf
```

```dart
// lib/icons/custom_icons.dart
import 'package:flutter/widgets.dart';

class CustomIcons {
  static const IconData home = IconData(0xe900, fontFamily: 'CustomIcons');
  static const IconData settings = IconData(0xe901, fontFamily: 'CustomIcons');
  static const IconData profile = IconData(0xe902, fontFamily: 'CustomIcons');
}
```

## Конвертация изображений в WebP

### Использование утилиты cwebp

```bash
# Установка (macOS)
brew install webp

# Конвертация PNG в WebP с качеством 80
cwebp -q 80 input.png -o output.webp

# Пакетная конвертация
for file in *.png; do
  cwebp -q 80 "$file" -o "${file%.png}.webp"
done
```

### Использование онлайн инструментов

- [Squoosh](https://squoosh.app/) — онлайн конвертер с визуальным сравнением
- [CloudConvert](https://cloudconvert.com/) — пакетная конвертация

### Автоматизация в CI/CD

```yaml
# .github/workflows/optimize-assets.yml
name: Optimize Assets

on:
  push:
    paths:
      - 'assets/**/*.png'

jobs:
  optimize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install WebP
        run: sudo apt-get install webp
      - name: Convert PNG to WebP
        run: |
          find assets -name "*.png" -exec sh -c '
            cwebp -q 80 "$1" -o "${1%.png}.webp"
          ' _ {} \;
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add assets/**/*.webp
          git commit -m "Convert images to WebP" || true
          git push
```

## Сравнение форматов

| Формат | Иконки | Изображения | Размер | Качество | Масштаб | Примечание |
|--------|--------|-------------|--------|----------|---------|------------|
| **Шрифт** | ✅ Рекомендуется | ❌ Не применимо | Очень малый | Отлично | ∞ | Только одноцветные |
| **WebP** | ✅ Цветные только | ✅ Рекомендуется | Малый | Отлично | Фиксированный | Требует версии 2x/3x |
| **PNG** | ⚠️ Не рекомендуется | ❌ Не рекомендуется | Большой | Отлично | Фиксированный | Устаревший |
| **SVG** | ❌ Запрещено | ⚠️ Особые случаи | Средний | Отлично | ∞ | Медленная отрисовка |
| **JPG** | ❌ Запрещено | ⚠️ Фото только | Малый | Хорошо | Фиксированный | Нет прозрачности |

## Исключения и особые случаи

### 1. Цветные иконки

Если иконка содержит несколько цветов и не может быть представлена шрифтом:

```dart
// ✅ Допустимо: цветная иконка в WebP
Widget colorfulIcon() {
  return Image.asset(
    'assets/icons/app_logo_color.webp',
    width: 48,
    height: 48,
  );
}

// Структура:
// assets/icons/app_logo_color.webp (1x: 48x48)
// assets/icons/2.0x/app_logo_color.webp (2x: 96x96)
// assets/icons/3.0x/app_logo_color.webp (3x: 144x144)
```

### 2. Динамическое изменение цвета изображения

Если требуется менять цвета элементов изображения динамически:

```dart
// ✅ Допустимо: SVG для динамического изменения цвета
Widget dynamicColorImage() {
  return SvgPicture.asset(
    'assets/images/themed_illustration.svg',
    // Обоснование: требуется динамическое изменение цвета
    // элементов иллюстрации в зависимости от темы
    colorFilter: ColorFilter.mode(
      Theme.of(context).primaryColor,
      BlendMode.srcIn,
    ),
  );
}
```

### 3. Фотографии высокого качества

Для фотографического контента WebP может не подходить:

```dart
// ✅ Допустимо: JPEG для фотографий
Widget highQualityPhoto() {
  return Image.asset(
    'assets/images/photo.jpg',
    fit: BoxFit.cover,
  );
}
```

## Проверка

- [ ] Все иконки используют шрифтовые IconData (Icons.*, кастомные шрифты)
- [ ] Цветные иконки в формате WebP с версиями 1x/2x/3x
- [ ] Изображения в формате WebP (или JPEG для фото)
- [ ] SVG не используется для иконок
- [ ] SVG для изображений имеет комментарий с обоснованием
- [ ] Нет PNG файлов для новых изображений
- [ ] Кастомные иконочные шрифты подключены в pubspec.yaml
- [ ] Все растровые иконки имеют версии для разных плотностей экрана

## Связанные правила

- **[FL-ASSETS-ICON-DENSITY](FL-ASSETS-ICON-DENSITY.md)** — Масштабирование растровых иконок для разных плотностей экрана
