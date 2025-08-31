# --- МЕТА ---
id: YOUR-RULE-ID                      # Уникальный ID (SCREAMING_SNAKE_CASE или kebab-case)
title: "Короткое, точное название"    # До 80 символов
status: draft                         # draft | stable | deprecated
severity: warning                     # info | warning | error
category: dart/...                    # eg: architecture/boundaries, dart/style, flutter/widgets
tags: [ ]                             # 5-7 тегов максимум
version: 1                            # Увеличивайте при изменениях логики
owners: [ "@team-arch", "@you" ]      # Кто отвечает за правило

# --- ДОКУМЕНТАЦИЯ / ПРИМЕРЫ ---
bad_snippet: docs/examples/bad/example-bad-001.dart
good_snippet: docs/examples/good/example-good-001.dart
references:
- "Короткая ссылка на внутренний гайд или внешнюю статью"

# --- ОБЛАСТЬ ПРИМЕНЕНИЯ ---
scope:
include_paths:
- "lib/**"                        # Сужайте до нужных слоёв/папок
exclude_paths:
- "test/**"
- "integration_test/**"
- "tool/**"

# --- ДЕТЕКТЫ ---
# Можно комбинировать списки запрещённых импортов/вызовов и произвольные regex-паттерны
detect:
disallowed_imports: [ ]             # eg: "package:cloud_firestore/cloud_firestore.dart"
disallowed_calls: [ ]               # eg: "FirebaseAuth.instance", "Dio("
allowlist_imports: [ ]              # Явно разрешённые (для снижения ложных срабатываний)
allowlist_paths: [ ]                # Папки, где разрешено исключение из правила

# Произвольные паттерны (мощнее обычных списков)
patterns:
# Пример:
# - id: short_id
#   description: "Человечное описание что именно ловим"
#   regex: "(?s)class\\s+\\w+Repository\\b[\\s\\S]*?\\bvoid\\s+(?!dispose\\b)(?!_)[a-zA-Z]\\w*\\s*\\("
#   flags: "s"

# --- СООБЩЕНИЕ ПОЛЬЗОВАТЕЛЮ ---
message: >
Одно чёткое объяснение нарушения + что делать вместо этого (не более 3 строк).

# --- АВТОФИКС / ПОДСКАЗКА ---
autofix:
suggestion_builder: minimal          # minimal | patch (если у вас поддерживается)
suggestion: >
Один безопасный совет как исправить. Не предлагайте рискованных переписываний.

# --- РЕЖИМ ИСПОЛНЕНИЯ ---
linter_rule:
coverage: ai                         # lint | ai | manual

# --- ПОДСКАЗКА ДЛЯ AI (КЛЮЧЕВОЕ!) ---
ai_hint: >
Конкретный алгоритм принятия решения:
- Где проверять (ссылаться на scope).
- Что считать нарушением (списки/паттерны).
- Что НЕ считать нарушением (важно для снижения ложноположительных).
- Особые случаи: 'part of', объединённые библиотеки, тестовые файлы.
- Формат и тон сообщения/подсказки.
- Ни в коем случае не предлагать несвязанные "Suggested change".

# --- ТЕСТЫ (ОБЯЗАТЕЛЬНО) ---
tests:
should_flag:
- path: "lib/some/feature/bad_file.dart"
content: |
// сюда минимальный, но репрезентативный пример нарушения
should_pass:
- path: "lib/some/feature/good_file.dart"
content: |
// сюда минимальный корректный пример (с пограничными случаями)