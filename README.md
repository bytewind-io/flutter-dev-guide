# Flutter/Dart Standards (doc-as-code)

Единые правила оформления кода и примеры «хорошо/плохо». Подход **doc-as-code**: всё хранится в Git, изменения — через PR.
Сайт рендерится на GitHub Pages (MkDocs Material). Структура удобна для людей и для ИИ-ревью (Cursor/Codex и др.).

## Порядок проверок в PR
1. Собственный статический линтер (отдельный пакет).
2. Форматирование/анализ/тесты.
3. ИИ-проверка (запускается только если линтер пройден).

## Подключение к проектам
- **submodule**: `git submodule add https://github.com/<org>/standards standards`
- **subtree**: `git subtree add --prefix=standards https://github.com/<org>/standards main --squash`

## Разработка сайта локально
```bash
pip install mkdocs-material
mkdocs serve
```
Открой `http://127.0.0.1:8000`.

## Структура
- `docs/rules/**` — канонические правила (1 правило = 1 файл)
- `docs/examples/{good|bad}` — сниппеты кода как отдельные .dart-файлы (включаются в правила)
- `docs/mappings/rules_map.json` — машинно‑читаемый маппинг для ИИ
- `docs/templates/**` — шаблоны
- `.github/workflows/docs-deploy.yml` — деплой GitHub Pages

## Линтер
Линтер остаётся **отдельным пакетом**. В правилах можно указывать `linter_rule`, а в `docs/mappings` вести таблицу соответствий.
