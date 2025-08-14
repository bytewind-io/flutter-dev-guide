---
id: ARCH-REPO-STATELESS
title: "Репозиторий статичен: никаких INIT/SETUP и скрытого состояния"
status: stable
severity: error
category: architecture/repository
tags: [clean-architecture, repository, stateless, idempotency, boundaries]
linter_rule:
coverage: ai
bad_snippet: docs/examples/bad/bad-repo-state-001.dart
good_snippet: docs/examples/good/good-repo-state-001.dart
references: []
ai_hint: >
  Flag repository classes that expose methods like init(), setup(), start(), bootstrap(), preload(), configure(), loadCache()
  or require a call order. Flag repositories that store mutable state affecting later calls. Suggest moving initialization to
  constructor/DI or to a separate UseCase/Service. Repository methods must be self-sufficient and return results based only on
  inputs + persistent data sources, never on prior repo method calls.
---

## Пояснение

Репозиторий — это **тонкая абстракция над источниками данных**. Он **не** должен иметь управляемое клиентом состояние и **не** должен требовать предварительных вызовов вроде `init()`, `setup()`, `bootstrap()` и т.п.  
Любой метод репозитория должен возвращать один и тот же результат при одинаковых входных параметрах и одинаковых внешних данных — **независимо от ранее вызванных методов**.

## Запрещено
- Публичные методы репозитория с семантикой инициализации/подготовки: `init()`, `setup()`, `start()`, `bootstrap()`, `preload()`, `configure()`, `loadCache()` и т.п.
- Внутреннее состояние, влияющее на ответы последующих методов (кроме прозрачного, опционального кеширования, которое **не требует** специальных вызовов и не меняет контракт).
- API, чей результат зависит от порядка вызовов (например, `init()` должен быть вызван до `submit()`).

## Разрешено
- Конструктор/DI для передачи зависимостей.
- Отдельный **UseCase/Service** (над репозиторием), который оркестрирует несколько вызовов репозитория и комбинирует результаты.
- Прозрачное кеширование **за интерфейсом** (без обязательного вызова `init()`).

## Плохо
```dart
--8<-- "docs/examples/bad/bad-repo-state-001.dart"
```

## Хорошо 
```dart
--8<-- "docs/examples/good/good-repo-state-001.dart"
```