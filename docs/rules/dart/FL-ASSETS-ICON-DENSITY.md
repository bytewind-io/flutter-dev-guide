---
id: FL-ASSETS-ICON-DENSITY
title: "Для растровых иконок добавляй версии всех плотностей экрана"
status: stable
severity: warning
category: flutter/assets
tags:
  - assets
  - icons
  - images
  - density
  - resolution
  - ui
version: 1
owners:
  - "@team-ui"
  - "@team-frontend"

# Проверяем структуру папок с assets
scope:
  include_paths:
    - "assets/**"
    - "pubspec.yaml"
  exclude_paths:
    - "test/**"
    - "integration_test/**"

detect:
  patterns:
    - id: missing_density_variants
      description: "Отсутствуют версии иконок для разных плотностей экрана"
      # Проверка наличия папок 2.0x, 3.0x для каждой иконки в assets
      regex: "assets/images/(?!.*/(2\\.0x|3\\.0x)/)"
      flags: "gm"

message: >
  Для растровой иконки отсутствуют версии для различных плотностей экрана.
  Необходимо добавить версии 1x, 2x, 3x (и опционально 4x) для корректного
  отображения на всех устройствах.

autofix:
  suggestion_builder: minimal
  suggestion: >
    Создайте подпапки с версиями разных плотностей: 2.0x/, 3.0x/, 4.0x/ (опционально)
    и разместите соответствующие версии иконок с правильными размерами.

linter_rule:
  coverage: manual

ai_hint: >
  1) Проверяй структуру папок assets на наличие растровых изображений (png, jpg, jpeg, webp).
  2) Нарушение: растровая иконка без версий для разных плотностей (отсутствуют папки 2.0x/, 3.0x/).
  3) НЕ флагируй: шрифтовые иконки (Icons.*, IconData), анимации, другие ресурсы (не иконки).
  4) НЕ флагируй: иконки, у которых есть хотя бы одна дополнительная версия плотности.
  5) Правильная структура: базовая иконка в корневой папке, версии 2x/3x/4x в соответствующих подпапках.
  6) Фокусируйся на растровых иконках UI (цветные иконки в WebP), а не на больших изображениях контента.
  7) ВАЖНО: Растровые иконки допустимы только для цветных иконок. Обычные иконки должны быть шрифтовыми (см. FL-UI-ICON-IMAGE-FORMAT).

bad_snippet: docs/examples/bad/bad-icon-density-001.dart
good_snippet: docs/examples/good/good-icon-density-001.dart
references:
  - "Flutter Assets documentation: https://docs.flutter.dev/ui/assets/assets-and-images"
  - "Declaring resolution-aware assets: https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware"

tests:
  should_flag:
    - path: "assets/images/icon.png"
      content: |
        # Только одна версия иконки без вариантов для разных плотностей
        # ❌ Отсутствуют: assets/images/2.0x/icon.png, assets/images/3.0x/icon.png

  should_pass:
    - path: "assets/images/icon.png"
      content: |
        # Базовая версия иконки (1x)
        # ✅ Присутствуют также:
        # - assets/images/2.0x/icon.png
        # - assets/images/3.0x/icon.png
        # - assets/images/4.0x/icon.png (опционально)

    - path: "lib/ui/home_page.dart"
      content: |
        import 'package:flutter/material.dart';

        class HomePage extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return IconButton(
              // ✅ Шрифтовая иконка не требует версий 2x/3x
              icon: Icon(Icons.home, size: 24),
              onPressed: () {},
            );
          }
        }

---

## Пояснение

> **⚠️ ВАЖНО**: Это правило применяется ТОЛЬКО к растровым иконкам (цветные иконки в WebP).
> Для обычных иконок обязательно используйте **шрифтовые иконки** (Icons.*, кастомные IconData).
> См. правило **[FL-UI-ICON-IMAGE-FORMAT](FL-UI-ICON-IMAGE-FORMAT.md)** для выбора правильного формата.

Для каждой растровой иконки необходимо добавлять версии для различных плотностей экрана, чтобы обеспечить четкое отображение на всех устройствах. Flutter автоматически выбирает подходящую версию иконки в зависимости от плотности экрана устройства.

### Требуемые версии

Для каждой растровой иконки необходимо создать:
- **1x** — базовый размер (размещается в корневой папке)
- **2x** — для экранов с высокой плотностью
- **3x** — для очень высокой плотности
- **4x** — для экстремально высокой плотности (при необходимости)

## Плохо

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/

# Структура файлов:
# assets/
#   images/
#     icon_home.png        # ❌ Только одна версия
#     icon_profile.png     # ❌ Только одна версия
#     icon_settings.png    # ❌ Только одна версия
```

**Проблема**: На устройствах с высокой плотностью экрана (Retina, AMOLED) иконки будут выглядеть размытыми или пикселизированными, так как Flutter будет масштабировать единственную доступную версию.

## Хорошо

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/

# Структура файлов:
# assets/
#   images/
#     icon_home.png        # 24x24 (1x)
#     icon_profile.png     # 24x24 (1x)
#     icon_settings.png    # 24x24 (1x)
#     2.0x/
#       icon_home.png      # 48x48 (2x)
#       icon_profile.png   # 48x48 (2x)
#       icon_settings.png  # 48x48 (2x)
#     3.0x/
#       icon_home.png      # 72x72 (3x)
#       icon_profile.png   # 72x72 (3x)
#       icon_settings.png  # 72x72 (3x)
#     4.0x/                # Опционально
#       icon_home.png      # 96x96 (4x)
#       icon_profile.png   # 96x96 (4x)
#       icon_settings.png  # 96x96 (4x)
```

```dart
// Использование в коде
class HomeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icon_home.png',
      width: 24,
      height: 24,
    );
  }
}
```

**Преимущество**: Flutter автоматически выбирает правильную версию иконки в зависимости от плотности экрана устройства:
- На обычном экране (mdpi) — используется версия 1x
- На Retina/Full HD (xhdpi) — используется версия 2x
- На AMOLED/4K (xxhdpi) — используется версия 3x
- На экстремально высоком разрешении — используется версия 4x

## Пример с разными размерами

Для иконки размером **24x24 pt** (points):

| Плотность | Множитель | Физический размер | Путь к файлу |
|-----------|-----------|-------------------|--------------|
| 1x (mdpi) | 1.0 | 24x24 px | `assets/images/icon.png` |
| 2x (xhdpi) | 2.0 | 48x48 px | `assets/images/2.0x/icon.png` |
| 3x (xxhdpi) | 3.0 | 72x72 px | `assets/images/3.0x/icon.png` |
| 4x (xxxhdpi) | 4.0 | 96x96 px | `assets/images/4.0x/icon.png` |

## Замечания

### Когда версии для разных плотностей не требуются

1. **Шрифтовые иконки (РЕКОМЕНДУЕТСЯ для иконок)**: Масштабируются бесконечно
   ```dart
   // ✅ Шрифтовые иконки не требуют версий 2x/3x
   Icon(Icons.home, size: 24)
   ```
   **ВАЖНО**: Для иконок обязательно используйте шрифтовые иконки (см. правило [FL-UI-ICON-IMAGE-FORMAT](FL-UI-ICON-IMAGE-FORMAT.md))

2. **Векторные изображения (SVG)**: Только для изображений, НЕ для иконок
   ```yaml
   flutter:
     assets:
       # ✅ SVG для изображения (с обоснованием)
       - assets/images/illustration.svg
   ```
   **ВАЖНО**: SVG запрещен для иконок! Используйте шрифтовые иконки. SVG допустим только для изображений в особых случаях (см. [FL-UI-ICON-IMAGE-FORMAT](FL-UI-ICON-IMAGE-FORMAT.md))

3. **Большие изображения контента**: Фотографии, баннеры (достаточно одной версии высокого разрешения)
   ```yaml
   flutter:
     assets:
       - assets/images/banner.webp  # ✅ Можно использовать одну версию
   ```

4. **Анимации и видео**: Форматы, которые сами управляют разрешением

### Рекомендации по оптимизации

1. **Используйте WebP**: Формат WebP обеспечивает лучшее сжатие с сохранением качества
2. **Минимизируйте размер**: Оптимизируйте PNG/WebP файлы через TinyPNG, ImageOptim
3. **4x — опционально**: Для большинства приложений достаточно версий до 3x
4. **Используйте шрифтовые иконки**: Для всех иконок используйте Icons.* или кастомные IconData (см. [FL-UI-ICON-IMAGE-FORMAT](FL-UI-ICON-IMAGE-FORMAT.md))

### Автоматическое создание версий

Можно использовать инструменты для автоматической генерации версий:
- ImageMagick
- Flutter Asset Generator пакеты
- Figma/Sketch экспорт с множителями

```bash
# Пример с ImageMagick
convert icon.png -resize 200% assets/images/2.0x/icon.png
convert icon.png -resize 300% assets/images/3.0x/icon.png
```

## Проверка

- [ ] Все растровые иконки UI имеют версии 1x, 2x, 3x
- [ ] Размеры версий кратны базовому размеру (2x, 3x, 4x)
- [ ] Файлы имеют одинаковые имена во всех папках
- [ ] Структура папок соответствует стандарту Flutter (2.0x/, 3.0x/, 4.0x/)
- [ ] Для иконок используются шрифтовые иконки (Icons.*, кастомные IconData)
- [ ] Изображения оптимизированы по размеру файла
