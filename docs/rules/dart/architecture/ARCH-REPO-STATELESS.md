---
id: ARCH-REPO-STATELESS
title: "Репозиторий статичен: никаких INIT/SETUP, без состояния, согласованный API"
status: stable
severity: error
category: architecture/repository
tags: [clean-architecture, repository, stateless, idempotency, boundaries, naming, api-shape, di]
linter_rule:
coverage: ai
bad_snippet: bad-repo-state-002.dart
good_snippet: good-repo-state-002.dart
references: []
ai_hint: >
  Flag repositories that:
   - expose init/setup/start/bootstrap/preload/configure/loadCache or require call order;
   - return Stream in public API (require Future instead), or mix Stream/Future variants like fetchX()/fetchXOnce();
   - contain unrelated methods (e.g., ThingsRepository.uploadImages);
   - return Map/dynamic instead of typed data models;
   - use overlong names like deleteThingsByType/searchThingsByTitle/fetchMyThings;
   - place dispose() not as the last method, or repository interface not at the end of the file;
   - are referenced directly by concrete class in UI/BLoC instead of via interface (DI).
  Suggest: single Future-based API (fetch(filter)); short names (fetch/search/deleteByType);
  filter-based queries (Empty/Ids/Text); interface at file end; dispose() last; depend on abstractions in UI/BLoC.
---

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
