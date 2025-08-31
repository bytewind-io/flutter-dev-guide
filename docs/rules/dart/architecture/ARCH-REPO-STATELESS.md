id: ARCH-REPO-STATELESS
title: "Репозиторий статичен: без init/setup, единый Future-API и корректные глаголы (fetch/create/update/delete)"
status: stable
severity: error
category: architecture/repository
tags:
- clean-architecture
- repository
- stateless
- idempotency
- boundaries
- naming
- api-shape
- di
  version: 3
  owners: [ "@arch-bot", "@team-data" ]

# Где проверяем
scope:
include_paths:
- "lib/**/repository/**"
- "lib/**/data/**"
- "lib/**/infra/**"
- "lib/**/**repository**.dart"
exclude_paths:
- "lib/**/ui/**"
- "lib/**/api/**"
- "lib/**/presentation/**"
- "lib/**/widget/**"
- "lib/**/view/**"
- "lib/**/bloc/**"
- "lib/**/cubit/**"
- "test/**"
- "integration_test/**"

# Детекторы нарушений
detect:
# Явные списки при необходимости можно дополнить
disallowed_imports: [ ]
disallowed_calls: [ ]
allowlist_imports:
- "dart:async"
allowlist_paths: [ ]

patterns:
# 1) init/setup/start/bootstrap/preload/... в *Repository (теперь вне зависимости от параметров)
- id: repo_init_like_method
description: "В репозитории найден init/setup/start/bootstrap/preload/configure/loadCache/warmup/open/connect — репозиторий должен быть бесстейтным."
regex: "(?s)(?:class|abstract\\s+class)\\s+\\w+Repository(?:I)?\\b[\\s\\S]*?\\b(?:Future\\s*<[^>]+>|Future|void)\\s+(?:init(?:[A-Z_].*)?|initialize(?:[A-Z_].*)?|setup(?:[A-Z_].*)?|start(?:[A-Z_].*)?|bootstrap(?:[A-Z_].*)?|preload(?:[A-Z_].*)?|configure(?:[A-Z_].*)?|loadCache(?:[A-Z_].*)?|warmup(?:[A-Z_].*)?|open(?:[A-Z_].*)?|connect(?:[A-Z_].*)?)\\s*\\("
flags: "s"

    # 2) Stream в публичном API репозитория (запрещено)
    - id: repo_public_stream_method
      description: "Публичный метод репозитория возвращает Stream — публичный API должен быть Future-based."
      regex: "(?s)(?:class|abstract\\s+class)\\s+\\w+Repository(?:I)?\\b[\\s\\S]*?\\bStream\\s*<[^>]+>\\s+(?!_)[a-z][A-Za-z0-9_]*\\s*\\("
      flags: "s"

    # 3) Публичный void (кроме dispose) — запрещено
    - id: repo_public_void_method_not_dispose
      description: "Публичный метод репозитория возвращает void (кроме dispose) — используйте Future<...>."
      regex: "(?s)(?:class|abstract\\s+class)\\s+\\w+Repository(?:I)?\\b[\\s\\S]*?\\bvoid\\s+(?!dispose\\b)(?!_)[a-z][A-Za-z0-9_]*\\s*\\("
      flags: "s"

    # 4) Публичный не‑Future возврат (int/bool/Model/Map и т.п.) — запрещено
    - id: repo_public_non_future_return
      description: "Публичный метод репозитория не возвращает Future — публичный API должен быть асинхронным."
      regex: "(?s)(?:class|abstract\\s+class)\\s+\\w+Repository(?:I)?\\b[\\s\\S]*?\\b(?!Future\\s*<[^>]+>|Future\\b|void\\b|Stream\\s*<[^>]+>|factory\\b|const\\b|static\\b)[A-Za-z_][A-Za-z0-9_<>?,\\[\\]\\s]*\\s+(?!_)[a-z][A-Za-z0-9_]*\\s*\\("
      flags: "s"

    # 5) Нарушение соглашения об именах: разрешены только fetch/create/update/delete
    #    Флагируем любой public-метод в *Repository, который НЕ начинается с этих глаголов (исключая dispose).
    - id: repo_disallowed_method_naming
      description: "Публичные методы репозитория должны начинаться с fetch/create/update/delete (например, get*/preload*/load*/list* — запрещены)."
      regex: "(?s)(?:class|abstract\\s+class)\\s+\\w+Repository(?:I)?\\b[\\s\\S]*?\\b(?:Future\\s*<[^>]+>|Future|void|[A-Za-z_][A-Za-z0-9_<>,\\s\\[\\]?]*)\\s+(?!_)(?!dispose\\b)(?!(?:fetch|create|update|delete)\\b)[a-z][A-Za-z0-9_]*\\s*\\("
      flags: "s"

message: >
Репозиторий должен быть бесстейтным и иметь единый Future-based API. Публичные методы
должны начинаться с fetch/create/update/delete. Запрещены init/setup/start/bootstrap/preload и пр.,
Stream в публичном API, public void (кроме dispose), и любые public-методы с именами вне allowed-глаголов.

autofix:
suggestion_builder: minimal
suggestion: >
Переименуйте методы на fetch/create/update/delete (например, getDistinctValues -> fetchDistinctValues).
Удалите/перенесите preload/init/setup в DI/конструктор реализации. Потоки вынесите в watcher-сервис,
публичные методы сделайте Future<...>.

linter_rule:
coverage: ai

ai_hint: >
Анализируй только классы/интерфейсы, имя которых заканчивается на 'Repository' или 'RepositoryI' (см. scope).
Флагируй:
• init/setup/start/bootstrap/preload/configure/loadCache/warmup/open/connect — независимо от параметров;
• public методы с Stream<...>;
• public void, кроме dispose;
• public методы, чьи имена НЕ начинаются с fetch|create|update|delete (игнорируй private: _name, и dispose).
Не флагируй код вне scope. Сообщение короткое, без нерелевантных советов.

# Примеры/тесты
tests:
should_flag:
- path: "lib/data/filters/repository/filter_repository.dart"
content: |
import 'package:injectable/injectable.dart';
import '../network/filter_data_api.dart';

        @LazySingleton(as: FilterRepositoryI)
        class FilterRepository implements FilterRepositoryI {
          FilterRepository({required FilterDataApiI api}) : _api = api;
          final FilterDataApiI _api;

          @override
          Future<List<String>> getDistinctValues(String field) { // ❌ имя не с fetch/create/update/delete
            return _api.fetchDistinctValuesForCurrentUser(field: field);
          }

          @override
          Future<Map<String, List<String>>> preload(Iterable<String> fields) async { // ❌ preload запрещён
            final entries = await Future.wait(
              fields.map((f) async {
                final values = await _api.fetchDistinctValuesForCurrentUser(field: f);
                return MapEntry(f, values);
              }),
            );
            return Map<String, List<String>>.fromEntries(entries);
          }
        }

        abstract class FilterRepositoryI {
          Future<List<String>> getDistinctValues(String field); // ❌ имя
          Future<Map<String, List<String>>> preload(Iterable<String> fields); // ❌ preload
        }

    - path: "lib/data/common/repository/preload_repo.dart"
      content: |
        class SomeRepository {
          Future<void> preloadCache() async {} // ❌ init-like/preload
          Stream<int> watch() => const Stream.empty(); // ❌ Stream в публичном API
          void clear() {} // ❌ public void
        }

should_pass:
- path: "lib/data/filters/repository/filter_repository_ok.dart"
content: |
import 'package:injectable/injectable.dart';
import '../network/filter_data_api.dart';

        abstract class FilterRepositoryI {
          Future<List<String>> fetchDistinctValues(String field);
          Future<Map<String, List<String>>> fetchDistinctValuesByFields(Iterable<String> fields);
        }

        @LazySingleton(as: FilterRepositoryI)
        class FilterRepository implements FilterRepositoryI {
          FilterRepository({required FilterDataApiI api}) : _api = api;
          final FilterDataApiI _api;

          @override
          Future<List<String>> fetchDistinctValues(String field) {
            return _api.fetchDistinctValuesForCurrentUser(field: field);
          }

          @override
          Future<Map<String, List<String>>> fetchDistinctValuesByFields(Iterable<String> fields) async {
            final entries = await Future.wait(
              fields.map((f) async {
                final values = await _api.fetchDistinctValuesForCurrentUser(field: f);
                return MapEntry(f, values);
              }),
            );
            return Map<String, List<String>>.fromEntries(entries);
          }

          void dispose() {} // допустимо, если размещён последним
        }

## Пояснение

Репозиторий — тонкая, **бесстейтная** абстракция над данными:

- **Никаких `init()/setup()`** и т.п.; результат методов не зависит от порядка вызовов.
- **Возвращает `Future<...>`** в публичном API. Если источник — `Stream`, конвертируйте внутри (`.first`, сборка в список и т.п.).  
  Потоки для живых обновлений обеспечиваются отдельными сервисами/наблюдателями, но не интерфейсом репозитория.
- **Единый запрос `fetch(FetchFilter filter)`** вместо вариаций `fetchXOnce/fetchMyY`. Фильтр передаётся параметром.
- **Именование краткое и предметное**: `fetch`, `search`, `deleteByType`, `deleteByUid`, `deleteByUids`.
- **Область ответственности**: только операции над своей сущностью. Никаких `uploadImages` в `ThingsRepository`.
- **Типы возврата — модели** (не `Map<String, dynamic>`).
- **Контракт доступа**: **доступ к репозиторию только через интерфейс** (инверсия зависимостей).  
  UI/BLoC объявляют зависимость от `*RepositoryI`; конкретная реализация прокидывается контейнером DI.  
  Запрещено в UI/BLoC импортировать и создавать `new ThingsRepository(...)` напрямую.
- **Стиль файла**: интерфейс репозитория (если объявлен в этом же файле) — **в конце файла**; метод `void dispose()` (если есть) — **последним**.

## Плохо (нарушения в сигнатурах, именах и ответственности)
```dart
--8<-- "docs/examples/bad/bad-repo-state-002.dart"
```

## Хорошо (единый Future-API, фильтры, краткие имена, интерфейс и dispose() в конце)
```dart
--8<-- "docs/examples/good/good-repo-state-002.dart"
```

## Дополнительно: не возвращаем `Map`, а используем модели
```dart
--8<-- "docs/examples/bad/bad-repo-map-return-001.dart"
```

```dart
--8<-- "docs/examples/good/good-repo-map-return-001.dart"
```

## Контракт доступа: только через интерфейс

=== "Плохо (UI/BLoC → конкретный класс репозитория)"
```dart
--8<-- "docs/examples/bad/bad-repo-direct-access-001.dart"
```

=== "Хорошо (UI/BLoC → интерфейс, DI проваливает реализацию)"
```dart
--8<-- "docs/examples/good/good-repo-direct-access-001.dart"
```
