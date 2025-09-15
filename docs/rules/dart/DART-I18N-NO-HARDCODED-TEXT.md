---
id: DART-I18N-NO-HARDCODED-TEXT
title: "Используй локализацию вместо хардкод текста"
status: stable
severity: warning
category: dart/i18n
tags:
  - internationalization
  - localization
  - hardcoded-text
  - user-facing-text
  - strings
version: 1
owners:
  - "@team-i18n"
  - "@team-frontend"

# Проверяем только UI слой и виджеты
scope:
  include_paths:
    - "lib/**/ui/**"
    - "lib/**/presentation/**"
    - "lib/**/widget/**"
    - "lib/**/widgets/**"
    - "lib/**/view/**"
    - "lib/**/views/**"
    - "lib/**/page/**"
    - "lib/**/pages/**"
    - "lib/**/screen/**"
    - "lib/**/screens/**"
  exclude_paths:
    - "lib/**/data/**"
    - "lib/**/infra/**"
    - "lib/**/network/**"
    - "lib/**/api/**"
    - "lib/**/constants/**"
    - "lib/**/config/**"
    - "test/**"
    - "integration_test/**"

detect:
  # Паттерны для обнаружения хардкод строк в UI-виджетах
  patterns:
    - id: hardcoded_text_widget
      description: "Хардкод текста в Text виджетах"
      regex: "Text\\s*\\(\\s*['\"][^'\"]*[А-Яа-яЁё\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\u0600-\u06ff\u0590-\u05ff\u0100-\u017f\u1e00-\u1eff\u0370-\u03ff\u0400-\u04ff][^'\"]*['\"]"
      flags: "gm"
    
    - id: hardcoded_text_label
      description: "Хардкод текста в label параметрах"
      regex: "label\\s*:\\s*['\"][^'\"]*[А-Яа-яЁё\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\u0600-\u06ff\u0590-\u05ff\u0100-\u017f\u1e00-\u1eff\u0370-\u03ff\u0400-\u04ff][^'\"]*['\"]"
      flags: "gm"
    
    - id: hardcoded_text_title
      description: "Хардкод текста в title параметрах"
      regex: "title\\s*:\\s*['\"][^'\"]*[А-Яа-яЁё\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\u0600-\u06ff\u0590-\u05ff\u0100-\u017f\u1e00-\u1eff\u0370-\u03ff\u0400-\u04ff][^'\"]*['\"]"
      flags: "gm"
    
    - id: hardcoded_text_hinttext
      description: "Хардкод текста в hintText параметрах"
      regex: "hintText\\s*:\\s*['\"][^'\"]*[А-Яа-яЁё\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\u0600-\u06ff\u0590-\u05ff\u0100-\u017f\u1e00-\u1eff\u0370-\u03ff\u0400-\u04ff][^'\"]*['\"]"
      flags: "gm"
    
    - id: hardcoded_text_tooltip
      description: "Хардкод текста в tooltip параметрах"
      regex: "tooltip\\s*:\\s*['\"][^'\"]*[А-Яа-яЁё\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\u0600-\u06ff\u0590-\u05ff\u0100-\u017f\u1e00-\u1eff\u0370-\u03ff\u0400-\u04ff][^'\"]*['\"]"
      flags: "gm"

  # Исключения - разрешённые случаи
  allowlist_patterns:
    # Интерполированные строки (может содержать переменные)
    - "\\$\\{"
    # Логирование и debug строки
    - "print\\s*\\("
    - "log\\s*\\("
    - "debugPrint\\s*\\("
    # Константы и конфиг
    - "static\\s+const\\s+String"
    # Assets пути
    - "assets/"
    # URL и схемы
    - "http[s]?://"
    - "ftp://"
    - "mailto:"
    # Технические строки (ключи, ID)
    - "[a-zA-Z0-9_]+_[a-zA-Z0-9_]+"
    # Правильное использование локализации
    - "S\\.of\\("
    - "AppLocalizations\\.of\\("
    - "context\\.l10n\\."
    - "\\.tr\\(\\)"
    - "Intl\\."

message: >
  Обнаружен хардкод текста на пользовательском интерфейсе. Используйте систему локализации 
  (например, AppLocalizations, context.l10n, tr()) вместо захардкоженных строк для 
  поддержки многоязычности приложения.

autofix:
  suggestion_builder: minimal
  suggestion: >
    Замените хардкод строку на вызов локализации: AppLocalizations.of(context).yourKey 
    или context.l10n.yourKey, добавив соответствующий ключ в файлы переводов.

linter_rule:
  coverage: ai

ai_hint: >
  1) Проверяй только файлы в UI/presentation/widget слоях (include_paths), НЕ флагируй data/api/config.
  2) Нарушение: строковые литералы с не-ASCII символами (кириллица, китайские, арабские и др.) 
     в параметрах Text(), label:, title:, hintText:, tooltip: и подобных UI-элементах.
  3) НЕ флагируй: интерполированные строки (${}), логирование, константы, asset пути, URLs.
  4) НЕ флагируй: технические строки с подчёркиваниями, ключи API, ID.
  5) НЕ флагируй: строки только из ASCII символов (английский текст пока допустим).
  6) КРИТИЧНО: НЕ флагируй правильное использование локализации: S.of(context), AppLocalizations.of(context), context.l10n, .tr(), Intl.
  7) Фокусируйся на пользовательских текстах, которые должны переводиться.

bad_snippet: docs/examples/bad/bad-hardcoded-text-001.dart
good_snippet: docs/examples/good/good-hardcoded-text-001.dart
references: 
  - "Flutter Internationalization guide: https://docs.flutter.dev/development/accessibility-and-localization/internationalization"

tests:
  should_flag:
    - path: "lib/feature/profile/ui/profile_page.dart"
      content: |
        import 'package:flutter/material.dart';
        
        class ProfilePage extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Профиль пользователя'), // ❌ хардкод кириллицы
              ),
              body: Column(
                children: [
                  TextField(
                    hintText: 'Введите ваше имя', // ❌ хардкод кириллицы
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Сохранить'), // ❌ хардкод кириллицы
                  ),
                ],
              ),
            );
          }
        }
    
    - path: "lib/widgets/tag_chip.dart"
      content: |
        class TagChip extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Chip(
              label: Text('Очистить все'), // ❌ хардкод кириллицы
              tooltip: 'Очистить все фильтры', // ❌ хардкод кириллицы
            );
          }
        }

  should_pass:
    - path: "lib/feature/profile/ui/profile_page.dart"
      content: |
        import 'package:flutter/material.dart';
        import 'package:flutter_gen/gen_l10n/app_localizations.dart';
        
        class ProfilePage extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.profileTitle), // ✅ локализация
              ),
              body: Column(
                children: [
                  TextField(
                    hintText: l10n.enterYourName, // ✅ локализация
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(l10n.save), // ✅ локализация
                  ),
                ],
              ),
            );
          }
        }
    
    - path: "lib/constants/api_constants.dart"
      content: |
        class ApiConstants {
          static const String baseUrl = 'https://api.example.com'; // ✅ техническая строка
          static const String userEndpoint = '/api/v1/users'; // ✅ техническая строка
        }
    
    - path: "lib/utils/logger.dart"
      content: |
        void logError(String message) {
          print('Error occurred: $message'); // ✅ логирование
          debugPrint('Debug info: некоторая информация'); // ✅ debug
        }
    
    - path: "lib/widgets/tag_widget.dart"
      content: |
        import 'package:flutter/material.dart';
        import '../generated/l10n.dart';
        
        class TagWidget extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            final tag = getTag();
            return Text(
              tag?.name ?? S.of(context).unknown, // ✅ правильное использование локализации
            );
          }
        }

## Плохо

```dart
--8<-- "docs/examples/bad/bad-hardcoded-text-001.dart"
```

## Хорошо

```dart
--8<-- "docs/examples/good/good-hardcoded-text-001.dart"
```

## Альтернативы

### 1. Flutter Localization (Recommended)

```dart
// pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter

// lib/l10n/app_en.arb
{
  "clearAll": "Clear all",
  "enterName": "Enter your name",
  "save": "Save"
}

// lib/l10n/app_ru.arb  
{
  "clearAll": "Очистить все",
  "enterName": "Введите ваше имя", 
  "save": "Сохранить"
}

// Usage
Text(AppLocalizations.of(context)!.clearAll)
```

### 2. Easy Localization Package

```dart
// pubspec.yaml
dependencies:
  easy_localization: ^3.0.0

// assets/translations/en.json
{
  "clearAll": "Clear all",
  "enterName": "Enter your name"
}

// Usage
Text('clearAll'.tr())
```

### 3. GetX Localization

```dart
// Usage with GetX
Text('clearAll'.tr)
```

## Исключения

Допустимые случаи хардкод текста:

1. **Технические строки**: API endpoints, конфигурация
2. **Debug/логирование**: Сообщения для разработчиков  
3. **Asset пути**: Пути к файлам ресурсов
4. **URLs и схемы**: Внешние ссылки
5. **Английский текст**: Пока что допустим (можно ужесточить отдельным правилом)

## Проверка

- [ ] Все пользовательские тексты используют систему локализации
- [ ] Нет хардкод строк с кириллицей, китайскими, арабскими символами в UI
- [ ] Файлы переводов содержат все необходимые ключи
- [ ] Технические строки остаются в константах/конфиге
- [ ] Debug сообщения не выводятся пользователю
