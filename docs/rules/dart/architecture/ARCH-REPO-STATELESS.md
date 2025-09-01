# Репозиторий статичен: без init/setup, единый Future-API и корректные глаголы

**ID:** `ARCH-REPO-STATELESS`  
**Статус:** Стабильный  
**Важность:** Ошибка  
**Категория:** Архитектура / Репозиторий  

## 🏷️ Теги
- clean-architecture
- repository
- stateless
- idempotency
- boundaries
- naming
- api-shape
- di

**Версия:** 3  
**Владельцы:** @arch-bot, @team-data

---

## 📍 Где проверяем

**Включаем:**
- `lib/**/repository/**`
- `lib/**/data/**`
- `lib/**/infra/**`
- `lib/**/**repository**.dart`

**Исключаем:**
- `lib/**/ui/**`
- `lib/**/api/**`
- `lib/**/presentation/**`
- `lib/**/widget/**`
- `lib/**/view/**`
- `lib/**/bloc/**`
- `lib/**/cubit/**`
- `test/**`
- `integration_test/**`

---

## 🔍 Детекторы нарушений

### Разрешенные импорты
- `dart:async`

### Паттерны для проверки

#### 1. ❌ Запрещены init/setup методы
**Описание:** В репозитории найден init/setup/start/bootstrap/preload/configure/loadCache/warmup/open/connect — репозиторий должен быть бесстейтным.

**Регулярка:** `(?:class|abstract\s+class)\s+\w+Repository(?:I)?\b[\s\S]*?\b(?:Future\s*<[^>]+>|Future|void)\s+(?:init(?:[A-Z_].*)?|initialize(?:[A-Z_].*)?|setup(?:[A-Z_].*)?|start(?:[A-Z_].*)?|bootstrap(?:[A-Z_].*)?|preload(?:[A-Z_].*)?|configure(?:[A-Z_].*)?|loadCache(?:[A-Z_].*)?|warmup(?:[A-Z_].*)?|open(?:[A-Z_].*)?|connect(?:[A-Z_].*)?)\s*\(`

#### 2. ❌ Запрещены Stream в публичном API
**Описание:** Публичный метод репозитория возвращает Stream — публичный API должен быть Future-based.

**Регулярка:** `(?:class|abstract\s+class)\s+\w+Repository(?:I)?\b[\s\S]*?\bStream\s*<[^>]+>\s+(?!_)[a-z][A-Za-z0-9_]*\s*\(`

#### 3. ❌ Запрещен public void (кроме dispose)
**Описание:** Публичный метод репозитория возвращает void (кроме dispose) — используйте Future<...>.

**Регулярка:** `(?:class|abstract\s+class)\s+\w+Repository(?:I)?\b[\s\S]*?\bvoid\s+(?!dispose\b)(?!_)[a-z][A-Za-z0-9_]*\s*\(`

#### 4. ❌ Запрещен не-Future возврат
**Описание:** Публичный метод репозитория не возвращает Future — публичный API должен быть асинхронным.

**Регулярка:** `(?:class|abstract\s+class)\s+\w+Repository(?:I)?\b[\s\S]*?\b(?!Future\s*<[^>]+>|Future\b|void\b|Stream\s*<[^>]+>|factory\b|const\b|static\b)[A-Za-z_][A-Za-z0-9_<>?,\[\]\s]*\s+(?!_)[a-z][A-Za-z0-9_]*\s*\(`

#### 5. ❌ Нарушение соглашения об именах
**Описание:** Публичные методы репозитория должны начинаться с fetch/create/update/delete (например, get*/preload*/load*/list* — запрещены).

**Регулярка:** `(?:class|abstract\s+class)\s+\w+Repository(?:I)?\b[\s\S]*?\b(?:Future\s*<[^>]+>|Future|void|[A-Za-z_][A-Za-z0-9_<>,\s\[\]?]*)\s+(?!_)(?!dispose\b)(?!(?:fetch|create|update|delete)\b)[a-z][A-Za-z0-9_]*\s*\(`

---

## 💬 Сообщение об ошибке

Репозиторий должен быть бесстейтным и иметь единый Future-based API. Публичные методы должны начинаться с fetch/create/update/delete. Запрещены init/setup/start/bootstrap/preload и пр., Stream в публичном API, public void (кроме dispose), и любые public-методы с именами вне allowed-глаголов.

---

## 🔧 Автоисправление

**Строитель предложений:** Минимальный

**Предложение:** Переименуйте методы на fetch/create/update/delete (например, getDistinctValues → fetchDistinctValues). Удалите/перенесите preload/init/setup в DI/конструктор реализации. Потоки вынесите в watcher-сервис, публичные методы сделайте Future<...>.

---

## 🧪 Примеры и тесты

### ❌ Должно флагироваться

#### Пример 1: Неправильные имена методов и preload
```dart:lib/data/filters/repository/filter_repository.dart
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
```

#### Пример 2: Различные нарушения
```dart:lib/data/common/repository/preload_repo.dart
class SomeRepository {
  Future<void> preloadCache() async {} // ❌ init-like/preload
  Stream<int> watch() => const Stream.empty(); // ❌ Stream в публичном API
  void clear() {} // ❌ public void
}
```

### ✅ Должно проходить

#### Пример: Правильная реализация
```dart:lib/data/filters/repository/filter_repository_ok.dart
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
```

---

## 📚 Пояснение

Репозиторий — тонкая, **бесстейтная** абстракция над данными:

### ✅ Что должно быть:
- **Никаких `init()/setup()`** и т.п.; результат методов не зависит от порядка вызовов
- **Возвращает `Future<...>`** в публичном API. Если источник — `Stream`, конвертируйте внутри (`.first`, сборка в список и т.п.)
- **Единый запрос `fetch(FetchFilter filter)`** вместо вариаций `fetchXOnce/fetchMyY`. Фильтр передаётся параметром
- **Именование краткое и предметное**: `fetch`, `search`, `deleteByType`, `deleteByUid`, `deleteByUids`
- **Область ответственности**: только операции над своей сущностью. Никаких `uploadImages` в `ThingsRepository`
- **Типы возврата — модели** (не `Map<String, dynamic>`)
- **Контракт доступа**: **доступ к репозиторию только через интерфейс** (инверсия зависимостей)
- **Стиль файла**: интерфейс репозитория (если объявлен в этом же файле) — **в конце файла**; метод `void dispose()` (если есть) — **последним**

### 🔄 Потоки для живых обновлений
Потоки для живых обновлений обеспечиваются отдельными сервисами/наблюдателями, но не интерфейсом репозитория.

### 🏗️ Контракт доступа
UI/BLoC объявляют зависимость от `*RepositoryI`; конкретная реализация прокидывается контейнером DI. Запрещено в UI/BLoC импортировать и создавать `new ThingsRepository(...)` напрямую.

---

## 📖 Примеры

### ❌ Плохо (нарушения в сигнатурах, именах и ответственности)
```dart
--8<-- "docs/examples/bad/bad-repo-state-002.dart"
```

### ✅ Хорошо (единый Future-API, фильтры, краткие имена, интерфейс и dispose() в конце)
```dart
--8<-- "docs/examples/good/good-repo-state-002.dart"
```

### ❌ Дополнительно: не возвращаем `Map`, а используем модели
```dart
--8<-- "docs/examples/bad/bad-repo-map-return-001.dart"
```

### ✅ Хорошо: возвращаем модели
```dart
--8<-- "docs/examples/good/good-repo-map-return-001.dart"
```

### 🔒 Контракт доступа: только через интерфейс

#### ❌ Плохо (UI/BLoC → конкретный класс репозитория)
```dart
--8<-- "docs/examples/bad/bad-repo-direct-access-001.dart"
```

#### ✅ Хорошо (UI/BLoC → интерфейс, DI проваливает реализацию)
```dart
--8<-- "docs/examples/good/good-repo-direct-access-001.dart"
```

---

## 🤖 AI-подсказка для линтера

Анализируй только классы/интерфейсы, имя которых заканчивается на 'Repository' или 'RepositoryI' (см. scope).

**Флагируй:**
- init/setup/start/bootstrap/preload/configure/loadCache/warmup/open/connect — независимо от параметров
- public методы с Stream<...>
- public void, кроме dispose
- public методы, чьи имена НЕ начинаются с fetch|create|update|delete (игнорируй private: _name, и dispose)

**Не флагируй код вне scope.** Сообщение короткое, без нерелевантных советов.
