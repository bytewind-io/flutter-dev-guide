---
id: DART-CLEAN-NO-CMT-LEGACY
title: "Запрещено поставлять закомментированный устаревший код"
status: stable
severity: error
category: dart/cleanliness
tags: [comments, dead-code, cleanup, readability]
linter_rule:
coverage: ai
bad_snippet: bad-commented-legacy-001.dart
good_snippet: good-commented-legacy-001.dart
references: []
ai_hint: >
  Flag commented-out code blocks (/* ... */, // ... lines) that contain code-like tokens (=>, ;, return, await, class, import).
  Ignore doc comments, TODO/FIXME with issue links, and code examples in docs directories.
  Suggest removing dead code and relying on VCS history, or moving alternative implementations to ADR/docs.
---

## Пояснение

Крупные **закомментированные куски кода** («на потом») запрещены. История кода хранится в Git — для этого не нужны «кладбища» в файлах.  
Комментированный код затрудняет чтение, мешает статическому анализу и ведёт к рассинхронизации.

## Как правильно организовать работу

1. **Удаляйте мёртвый код**, полагаясь на историю Git (всегда можно `git blame`/`git show`/`git revert`).  
2. Если нужен альтернативный подход — **опишите его в документации** или добавьте пример в `docs/examples/`.  
3. Если функциональность может понадобиться позже — используйте **feature‑flag/конфиги**, а не комментирование.  
4. В PR допускаются только короткие служебные комментарии: `// TODO(#ISSUE): ...` (до 120 символов).  
5. Любой найденный «закомментированный код» — повод **заблокировать PR** до удаления.

## Допустимые исключения

- Док‑комментарии (`///`) для публичных API.  
- Короткие `TODO/FIXME` с ссылкой на задачу.  
- Примеры кода в документации (папка `docs/`) и markdown.

## Плохо
```dart
--8<-- "docs/examples/bad/bad-commented-legacy-001.dart"
```

## Хорошо
```dart
--8<-- "docs/examples/good/good-commented-legacy-001.dart"
```

## Детектирование в CI (опционально)

Добавьте проверку `no-commented-code.yml` (смотри в `.github/workflows/`) и скрипт `docs/tools/check-commented-code.sh`.  
Порог — **0**: любые найденные блоки считаются нарушением.

