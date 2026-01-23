---
id: FL-UI-ICON-IMAGE-FORMAT
title: "Рекомендации по использованию иконок и изображений"
status: stable
severity: warning
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
    - id: svg_asset_as_icon
      description: "Использование SVG файла (через .asset) в качестве иконки"
      regex: "(?:Icon|IconButton)\\s*\\([^)]*SvgPicture\\.asset\\s*\\([^)]*\\.svg"
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
    SVG для иконок не рекомендуется. Если необходимо - используйте SvgPicture.string()
    со встроенным SVG кодом вместо SvgPicture.asset() с файлом.

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

### SVG не рекомендуется для иконок

**Не рекомендуется**: Использование формата SVG в качестве иконок.

**Причины**:
- Медленная отрисовка (парсинг XML)
- Большой размер файла по сравнению со шрифтами
- Дополнительная зависимость (flutter_svg)
- Повышенное использование памяти
- Проблемы с производительностью при множественном использовании

**Если SVG необходим** (анимированные иконки, сложная графика):
- ✅ **Используйте** `SvgPicture.string()` со встроенным SVG кодом
- ❌ **Избегайте** `SvgPicture.asset()` с файлом

**Преимущества `SvgPicture.string()`**:
- Меньше файлов в проекте
- Быстрее загрузка (не нужно читать файл)
- Явно показывает исключительный случай
- Легче заметить в code review
- Можно использовать константу

```dart
// ❌ Плохо: SVG файл для иконки
IconButton(
  icon: SvgPicture.asset('assets/icons/custom.svg'),
  onPressed: () {},
)

// ✅ Допустимо: SVG строка для особых случаев
class AppSvgIcons {
  static const String customIcon = '''
    <svg width="24" height="24" viewBox="0 0 24 24">
      <path d="M12 2L2 7l10 5 10-5-10-5z"/>
    </svg>
  ''';
}

IconButton(
  icon: SvgPicture.string(AppSvgIcons.customIcon),
  onPressed: () {},
)
```

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
          // ❌ ОШИБКА 1: SVG используется как иконка
          // ❌ ОШИБКА 2: Магическая строка вместо константы
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg', // Хардкод пути
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          // ❌ ОШИБКА 1: PNG иконка вместо шрифтовой
          // ❌ ОШИБКА 2: Магическая строка
          IconButton(
            icon: Image.asset(
              'assets/icons/search.png', // Хардкод пути
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ❌ PNG для изображения (должен быть WebP) + магическая строка
          Image.asset('assets/images/banner.png'), // Хардкод

          // ❌ SVG для изображения без обоснования + магическая строка
          SvgPicture.asset('assets/images/logo.svg'), // Хардкод

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
5. Магические строки с путями → риск опечаток, нет автодополнения, сложность рефакторинга

## Хорошо

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ✅ Константы для путей к ассетам
class AppImages {
  AppImages._();

  static const String banner = 'assets/images/banner.webp';
  static const String logo = 'assets/images/logo.svg';
}

class AppIcons {
  AppIcons._();

  // Шрифтовые иконки
  static const IconData settings = Icons.settings;
  static const IconData search = Icons.search;
  static const IconData home = Icons.home;
  static const IconData person = Icons.person;

  // Цветные растровые иконки
  static const String coloredBadge = 'assets/icons/colored_badge.webp';
}

class GoodExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Example'),
        actions: [
          // ✅ Шрифтовая иконка через константу
          IconButton(
            icon: Icon(AppIcons.settings),
            onPressed: () {},
          ),
          // ✅ Шрифтовая иконка через константу
          IconButton(
            icon: Icon(AppIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ WebP для изображения + константа
          Image.asset(AppImages.banner),

          // ✅ SVG для изображения с обоснованием + константа
          // Используется SVG для динамического изменения цвета логотипа
          SvgPicture.asset(
            AppImages.logo,
            colorFilter: ColorFilter.mode(
              Theme.of(context).primaryColor,
              BlendMode.srcIn,
            ),
          ),

          // ✅ Шрифтовые иконки через константы
          Row(
            children: [
              Icon(AppIcons.home, size: 24),
              Icon(AppIcons.person, size: 24),
            ],
          ),

          // ✅ Цветная растровая иконка в WebP + константа + версии 2x/3x
          Image.asset(
            AppIcons.coloredBadge,
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

## Организация путей к ассетам

### Вынос путей в константы

**Рекомендуется**: Выносить пути к ассетам в отдельные классы-константы для избежания опечаток и централизации управления ресурсами.

**Преимущества**:
- Отсутствие магических строк в коде
- Защита от опечаток (compile-time проверка)
- Единая точка изменения при рефакторинге
- Автодополнение в IDE
- Легко найти все использования ассета

### Структура классов

```dart
// lib/core/constants/app_images.dart
class AppImages {
  AppImages._(); // Приватный конструктор

  // Изображения
  static const String banner = 'assets/images/banner.webp';
  static const String logoBg = 'assets/images/logo_bg.webp';
  static const String placeholder = 'assets/images/placeholder.webp';

  // Цветные растровые иконки (требуют версии 2x/3x)
  static const String premiumBadge = 'assets/icons/premium_badge.webp';
  static const String coloredStar = 'assets/icons/colored_star.webp';
}

// lib/core/constants/app_icons.dart
class AppIcons {
  AppIcons._(); // Приватный конструктор

  // Шрифтовые иконки (основной способ)
  static const IconData home = Icons.home;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;

  // Кастомные шрифтовые иконки
  static const IconData customStar = IconData(0xe900, fontFamily: 'CustomIcons');
  static const IconData customHeart = IconData(0xe901, fontFamily: 'CustomIcons');
}
```

### Использование

```dart
// ❌ ПЛОХО: Магические строки
class BadExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/banner.webp'), // Опечатка не будет найдена
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile_pic.webp'),
        ),
      ],
    );
  }
}

// ✅ ХОРОШО: Использование констант
class GoodExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.banner), // Автодополнение, проверка на этапе компиляции
        CircleAvatar(
          backgroundImage: AssetImage(AppImages.placeholder),
        ),
        Icon(AppIcons.home), // Шрифтовая иконка через константу
      ],
    );
  }
}
```

### Группировка по категориям

Для больших проектов рекомендуется группировать ассеты по категориям:

```dart
// lib/core/constants/app_assets.dart
class AppAssets {
  AppAssets._();

  static const images = _Images();
  static const icons = _Icons();
  static const animations = _Animations();
}

class _Images {
  const _Images();

  // Баннеры
  final String homeBanner = 'assets/images/banners/home.webp';
  final String promoBanner = 'assets/images/banners/promo.webp';

  // Аватары
  final String defaultAvatar = 'assets/images/avatars/default.webp';
  final String placeholder = 'assets/images/avatars/placeholder.webp';

  // Иллюстрации (SVG с обоснованием)
  final String emptyState = 'assets/images/illustrations/empty.svg';
}

class _Icons {
  const _Icons();

  // Шрифтовые иконки
  final IconData home = Icons.home;
  final IconData search = Icons.search;

  // Цветные растровые иконки
  final String premium = 'assets/icons/premium.webp';
  final String verified = 'assets/icons/verified.webp';
}

class _Animations {
  const _Animations();

  final String loading = 'assets/animations/loading.json';
  final String success = 'assets/animations/success.json';
}

// Использование
Image.asset(AppAssets.images.homeBanner);
Icon(AppAssets.icons.home);
```

### Генерация констант

Для автоматической генерации классов с константами используйте:

**flutter_gen** (рекомендуется):
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_gen: ^5.0.0

flutter_gen:
  output: lib/gen/
  line_length: 80

  integrations:
    flutter_svg: true

flutter:
  assets:
    - assets/images/
    - assets/icons/
```

```dart
// Автоматически генерируется в lib/gen/assets.gen.dart
import 'package:flutter_gen/gen_l10n/assets.gen.dart';

// Использование
Image.asset(Assets.images.banner.path);
Icon(Assets.icons.home); // Для шрифтовых иконок
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
| **SVG** | ⚠️ Не рекомендуется* | ⚠️ Особые случаи | Средний | Отлично | ∞ | *Если нужно - .string() |
| **JPG** | ❌ Не подходит | ⚠️ Фото только | Малый | Хорошо | Фиксированный | Нет прозрачности |

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

### 2. SVG для иконок (исключительные случаи)

Если SVG необходим для иконки (анимированная иконка, сложная графика):

```dart
// ❌ ПЛОХО: SVG файл для иконки
IconButton(
  icon: SvgPicture.asset('assets/icons/animated.svg'),
  onPressed: () {},
)

// ✅ ДОПУСТИМО: SVG строка для иконки
// lib/core/constants/app_svg_icons.dart
class AppSvgIcons {
  AppSvgIcons._();

  // SVG код хранится как константа
  static const String animatedIcon = '''
    <svg width="24" height="24" viewBox="0 0 24 24">
      <path d="M12 2L2 7l10 5 10-5-10-5z"/>
      <circle cx="12" cy="12" r="3"/>
    </svg>
  ''';

  static const String customShape = '''
    <svg width="24" height="24" viewBox="0 0 24 24">
      <polygon points="12,2 15,8 22,9 17,14 18,21 12,17 6,21 7,14 2,9 9,8"/>
    </svg>
  ''';
}

// Использование
IconButton(
  icon: SvgPicture.string(
    AppSvgIcons.animatedIcon,
    width: 24,
    height: 24,
    colorFilter: ColorFilter.mode(
      Colors.blue,
      BlendMode.srcIn,
    ),
  ),
  onPressed: () {},
)
```

**Преимущества SVG строки перед файлом**:
- ✅ Меньше файлов в assets
- ✅ Быстрее загрузка (без чтения файла)
- ✅ Явно видно в коде, что это исключение
- ✅ Легче заметить в code review
- ✅ Централизованное хранение в константах

### 3. Динамическое изменение цвета изображения

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

### 4. Фотографии высокого качества

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
- [ ] SVG для иконок используется только в исключительных случаях
- [ ] SVG для иконок используется через SvgPicture.string(), а не .asset()
- [ ] SVG строки вынесены в константы (AppSvgIcons)
- [ ] SVG для изображений имеет комментарий с обоснованием
- [ ] Нет PNG файлов для новых изображений
- [ ] Кастомные иконочные шрифты подключены в pubspec.yaml
- [ ] Все растровые иконки имеют версии для разных плотностей экрана
- [ ] Пути к ассетам вынесены в классы-константы (AppImages, AppIcons)
- [ ] Нет магических строк с путями к ассетам в коде виджетов

## Связанные правила

- **[FL-ASSETS-ICON-DENSITY](FL-ASSETS-ICON-DENSITY.md)** — Масштабирование растровых иконок для разных плотностей экрана
