# Стандарты Flutter/Dart

Этот сайт описывает единые правила оформления кода и примеры «хорошо/плохо», пригодные как для людей, так и для ИИ-агентов (проверка PR, подсказки, автоисправления).

## 🎯 Принципы

- **Doc-as-code**: документация живёт в Git, правится через PR и code-review
- **Человек + ИИ**: структура и форматы удобны для чтения и машинной загрузки (RAG)
- **Порядок проверок в PR**:
  1. Статический линтер (`static_analyze_av`)
  2. Тесты/анализ
  3. ИИ-проверка (запускается только если линтер прошёл)
- **Трассируемость**: каждое правило документа привязано к конкретным проверкам линтера (если такие есть)

## 📚 Основные правила

### 🏗️ Архитектура
- **[ARCH-DS-NO-DIRECT-ACCESS](rules/dart/ARCH-DS-NO-DIRECT-ACCESS.md)** - UI и BLoC не обращаются к Firebase/SQLite/HTTP напрямую
- **[ARCH-REPO-STATELESS](rules/dart/architecture/ARCH-REPO-STATELESS.md)** - Репозиторий статичен: никаких INIT/SETUP и скрытого состояния

### 🎨 Data-классы и модели
- **[DART-DATA-REQ-CTOR](rules/dart/DART-DATA-REQ-CTOR.md)** - Строгие конструкторы с `required` для всех полей
- **[DART-DATA-EQUATABLE](rules/dart/DART-DATA-EQUATABLE.md)** - Наследование от `Equatable` для value equality
- **[DART-DATA-FACTORY](rules/dart/DART-DATA-FACTORY.md)** - Factory конструкторы для сценариев с отсутствующими полями

### 🔤 Enum и типизация
- **[DART-DATA-ENUM](rules/dart/DART-DATA-ENUM.md)** - Enum вместо магических чисел + безопасный `fromValue`
- **[DART-DATA-ENUM-UNKNOWN](rules/dart/DART-DATA-ENUM-UNKNOWN.md)** - Обработка неизвестных значений enum
- **[DART-DATA-JSON](rules/dart/DART-DATA-JSON.md)** - JSON сериализация с `enum.value` и `fromValue`

### 📋 Работа со списками
- **[DART-LIST-SAFE-ACCESS](rules/dart/DART-LIST-SAFE-ACCESS.md)** - Безопасный доступ к элементам списка с проверкой индексов

### 🧹 Качество кода
- **[DART-CLEAN-NO-CMT-LEGACY](rules/dart/quality/DART-CLEAN-NO-CMT-LEGACY.md)** - Запрещено поставлять закомментированный устаревший код

## 🚀 Быстрый старт

1. **Добавь репозиторий стандартов** как submodule или subtree
2. **Используй шаблон правила** из `docs/templates/rule-template.md`
3. **Примеры кода кладём** в `docs/examples/{good|bad}` и включаем в правило

## 🔧 Интеграция с проектами

### Git Submodule/Subtree
```bash
# Добавление как submodule
git submodule add <repo-url> docs/standards

# Добавление как subtree
git subtree add --prefix=docs/standards <repo-url> main --squash
```

### CI/CD интеграция
В проектах настраиваем проверки в следующем порядке:
1. Линтер (`static_analyze_av` через `dart analyze`)
2. `dart format/dart test`
3. ИИ-ревью (читает `rules_map.json` из стандарта)

## 🤖 AI-интеграция

Для ИИ-агентов (Cursor, Codex и др.) предоставляется машинно-читаемый маппинг правил в `docs/mappings/rules_map.json`.

## 📋 Покрытие проверок

- **Lint**: автоматические проверки линтером
- **AI**: проверки ИИ-агентами на основе правил
- **Manual**: ручные проверки в code review

## 🔗 Ссылки

- [Правила Dart](rules/dart/)
- [Шаблоны](templates/)
- [Примеры](examples/)
- [Маппинг правил](mappings/)
- [Руководства](guides/)
- [Flutter стандарты](flutter/)
