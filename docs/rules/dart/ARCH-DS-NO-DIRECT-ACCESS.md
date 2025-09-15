---
id: ARCH-DS-NO-DIRECT-ACCESS
title: "UI и BLoC не обращаются к Firebase/SQLite/HTTP напрямую (НЕ флагировать создание Filter объектов)"
status: stable
severity: error
category: architecture/boundaries
tags:
  - clean-architecture
  - repository
  - bloc
  - ui
  - datasource
version: 5
owners:
  - "@arch-bot"
  - "@team-arch"

# Проверяем только слой презентации
scope:
  include_paths:
    - "lib/**/ui/**"
    - "lib/**/presentation/**"
    - "lib/**/widget/**"
    - "lib/**/view/**"
    - "lib/**/bloc/**"
    - "lib/**/cubit/**"
  exclude_paths:
    - "lib/**/data/**"
    - "lib/**/infra/**"
    - "lib/**/repository/**"
    - "lib/**/repositories/**"
    - "lib/**/datasource/**"
    - "lib/**/datasources/**"
    - "lib/**/api/**"
    - "lib/**/apis/**"
    - "lib/**/network/**"
    - "lib/**/networks/**"
    - "lib/**/service/**"
    - "lib/**/services/**"
    - "test/**"
    - "integration_test/**"

detect:
  # Явные нарушения: SDK источников данных и прямые вызовы клиентов
  disallowed_imports:
    # Firebase
    - "package:cloud_firestore/cloud_firestore.dart"
    - "package:firebase_auth/firebase_auth.dart"
    - "package:firebase_database/firebase_database.dart"
    - "package:firebase_storage/firebase_storage.dart"
    # HTTP/GraphQL
    - "package:dio/dio.dart"
    - "package:http/http.dart"
    - "package:graphql_flutter/graphql_flutter.dart"
    # SQL/NoSQL/ORM/локальные БД
    - "package:sqflite/sqflite.dart"
    - "package:isar/isar.dart"
    - "package:hive/hive.dart"
    - "package:hive_flutter/hive_flutter.dart"
    - "package:drift/drift.dart"
    - "package:objectbox/objectbox.dart"
    - "package:realm/realm.dart"
    # Локальные/системные хранилища
    - "package:shared_preferences/shared_preferences.dart"
    - "package:path_provider/path_provider.dart"

  disallowed_calls:
    # Firebase singletons
    - "FirebaseFirestore.instance"
    - "FirebaseAuth.instance"
    - "FirebaseDatabase.instance"
    - "FirebaseStorage.instance"
    # Сетевые клиенты
    - "Dio("
    - "http.get("
    - "http.post("
    - "http.put("
    - "http.delete("
    # Низкоуровневые сокеты/клиенты
    - "HttpClient("
    - "WebSocket.connect("
    # Локальные хранилища
    - "SharedPreferences.getInstance("
    - "Isar.open("
    - "Hive.openBox("

  # КРИТИЧНО: Разрешённые паттерны для доменных объектов
  allowed_domain_patterns:
    # Фильтры для репозиториев (параметры запросов)
    - ".*Filter\\("
    - ".*ThingsFilter\\("
    - "FavoriteThingsFilter\\("
    - "EmptyThingsFilter\\("
    - "TagThingsFilter\\("
    - "MultipleTagsThingsFilter\\("
    - "TextSearchThingsFilter\\("
    # Доменные модели и entities
    - ".*Model\\("
    - ".*Entity\\("
    - ".*Request\\("
    - ".*Response\\("

  # Явно разрешаем инфраструктурные утилиты презентационного слоя,
  # чтобы исключить ложные срабатывания.
  allowlist_imports:
    - "package:rxdart/rxdart.dart"
    - "package:stream_transform/stream_transform.dart"
    - "package:bloc_concurrency/bloc_concurrency.dart"
    - "package:equatable/equatable.dart"
    - "package:collection/collection.dart"
    - "package:meta/meta.dart"
    - "dart:async"

  # Дополнительная страховка: даже если scope будет проигнорирован,
  # эти пути считаем безопасными и не флагируем.
  allowlist_paths:
    - "lib/**/data/**"
    - "lib/**/infra/**"
    - "lib/**/repository/**"
    - "lib/**/repositories/**"
    - "lib/**/datasource/**"
    - "lib/**/datasources/**"
    - "lib/**/api/**"
    - "lib/**/apis/**"
    - "lib/**/network/**"
    - "lib/**/networks/**"
    - "lib/**/service/**"
    - "lib/**/services/**"
    # ВРЕМЕННО: пока AI не понимает allowed_domain_patterns
    - "lib/**/bloc/home_bloc/**"

message: >
  Обнаружен прямой импорт SDK источников данных или вызов API в UI/BLoC слое.
  Проверьте: если это создание доменных объектов (*Filter, *Model, *Entity) - это НЕ нарушение.
  Нарушение только при прямых вызовах Firebase.instance, http.get(), sqflite и подобных.
  Вынесите реальный доступ к данным в data/infra слой через Repository интерфейсы.

autofix:
  suggestion_builder: minimal
  suggestion: >
    ВНИМАНИЕ: Создание объектов FavoriteThingsFilter(), TagThingsFilter() - это НЕ нарушение!
    Это доменные объекты-параметры для репозитория. Игнорируйте это предупреждение, если видите только создание *Filter().

linter_rule:
  coverage: ai

ai_hint: >
  КРИТИЧНО: НЕ ФЛАГИРУЙ СТРОКИ С СОЗДАНИЕМ ФИЛЬТРОВ!
  1) Если видишь "filter = const FavoriteThingsFilter()" или "filter = TagThingsFilter(" — ПРОПУСТИ!
  2) Эти строки НЕ являются нарушением архитектуры — это создание параметров для репозитория.
  3) Нарушение ТОЛЬКО: import firebase/http/sqflite ИЛИ прямые вызовы .instance/.get()/.post().
  4) Прежде чем флагировать: проверь путь файла (только include_paths, никогда exclude_paths).
  5) Если файл lib/**/bloc/home_bloc/** — НЕ ФЛАГИРУЙ (temporary allowlist).
  6) АБСОЛЮТНО ЗАПРЕЩЕНО флагировать: *Filter(), *Model(), *Entity(), *Request(), *Response().
  7) Игнорируй утилиты: rxdart, bloc_concurrency, get_it, injectable.
  8) НЕ предлагай фиксы для data/api/network — это корректный слой.

bad_snippet: docs/examples/bad/bad-datasource-in-bloc-001.dart
good_snippet: docs/examples/good/good-datasource-in-bloc-001.dart
references: [ ]

tests:
  should_flag:
    - path: "lib/module/home/presentation/bloc/home_bloc.dart"
      content: |
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:cloud_firestore/cloud_firestore.dart'; // ❌
        class HomeBloc extends Bloc<int, int> {
          HomeBloc(): super(0) {
            on<int>((e, emit) async {
              final uid = "x";
              await FirebaseFirestore.instance // ❌
                  .collection('item')
                  .add({'userId': uid});
              emit(state + 1);
            });
          }
        }
    - path: "lib/feature/auth/presentation/bloc/auth_bloc.dart"
      content: |
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:firebase_auth/firebase_auth.dart'; // ❌
        class AuthBloc extends Bloc<int, int> {
          AuthBloc(): super(0) {
            on<int>((e, emit) {
              final uid = FirebaseAuth.instance.currentUser?.uid; // ❌
              emit(state + (uid == null ? 0 : 1));
            });
          }
        }

  should_pass:
    - path: "lib/network/filter_data_api.dart"
      content: |
        import 'package:cloud_firestore/cloud_firestore.dart';
        import 'package:firebase_auth/firebase_auth.dart';
        import 'package:injectable/injectable.dart';

        @Injectable(as: FilterDataApiI)
        class FilterDataApiFirebase implements FilterDataApiI {
          FilterDataApiFirebase();

          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          final FirebaseAuth _auth = FirebaseAuth.instance;

          @override
          Future<List<String>> fetchDistinctValuesForCurrentUser({
            required String field,
          }) async {
            final userId = _auth.currentUser?.uid ?? '';
            if (userId.isEmpty) return const [];

            final snapshot = await _firestore
                .collection('item')
                .where('userId', isEqualTo: userId)
                .get();

            final values = <String>{};
            for (final doc in snapshot.docs) {
              final data = doc.data()[field];
              if (data is List) {
                for (final v in data) {
                  final s = v?.toString().trim();
                  if (s != null && s.isNotEmpty) values.add(s);
                }
              } else if (data != null && data is! Map) {
                final s = data.toString().trim();
                if (s.isNotEmpty) values.add(s);
              }
            }

            final list = values.toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
            return list;
          }
        }

        abstract class FilterDataApiI {
          Future<List<String>> fetchDistinctValuesForCurrentUser({
            required String field,
          });
        }

    - path: "lib/feature/users/data/user_repository_impl.dart"
      content: |
        import 'package:cloud_firestore/cloud_firestore.dart'; // допустимо: data слой
        class UserRepositoryImpl {
          final FirebaseFirestore _db;
          UserRepositoryImpl(this._db);
          Future<void> saveUser(String id) => _db.collection('users').doc(id).set({'id': id});
        }

    - path: "lib/module/home/bloc/home_bloc/home_bloc.dart"
      content: |
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:rxdart/rxdart.dart'; // ✅ допустимо
        typedef Evt<X> = EventTransformer<X>;
        Evt<E> debounceSwitchMap<E>(Duration d) =>
          (events, mapper) => events.debounceTime(d).switchMap(mapper);
        class HomeBloc extends Bloc<int, int> {
          HomeBloc(): super(0) {
            on<int>((e, emit) => emit(state + 1), transformer: debounceSwitchMap(const Duration(milliseconds: 300)));
          }
        }

    - path: "lib/module/home/bloc/home_bloc.dart"
      content: |
        import 'package:bloc/bloc.dart';
        import '../../repository/things_repository/fetch_filter.dart';
        import '../../repository/things_repository/thing_repository.dart';
        
        class HomeBloc extends Bloc<HomeEvent, HomeState> {
          HomeBloc({required ThingRepositoryI thingRepository})
              : _thingRepository = thingRepository,
                super(const HomeState());
        
          final ThingRepositoryI _thingRepository;
        
          void _applyTagFilters(Set<String> tagIds) {
            // ✅ Создание доменных фильтров - это правильно
            FetchThingsFilter filter;
            if (tagIds.isEmpty) {
              filter = const EmptyThingsFilter();
            } else if (tagIds.length == 1) {
              filter = TagThingsFilter(tagId: tagIds.first);
            } else {
              filter = MultipleTagsThingsFilter(tagIds: tagIds);
            }
            
            // ✅ Использование репозитория через интерфейс - это правильно
            _thingRepository.fetch(filter);
          }
        }


## Плохо (BLoC)

```dart
--8
<
--
"docs/examples/bad/bad-datasource-in-
bloc
-
001
.
dart
"
```

## Хорошо (BLoC)

```dart
--8
<
--
"docs/examples/good/good-datasource-in-
bloc
-
001
.
dart
"
```

## Плохо (UI Widget)

```dart
--8
<
--
"docs/examples/bad/bad-datasource-in-
widget
-
001
.
dart
"
```

## Хорошо (UI Widget)

```dart
--8
<
--
"docs/examples/good/good-datasource-in-
widget
-
001
.
dart
"
```

## Альтернативы

### 1. Repository Pattern

```dart
abstract class UserRepository {
  Future<User?> getCurrentUser();

  Future<void> saveUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._auth, this._firestore);

  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Future<void> saveUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
}
```

### 2. Use Case Pattern

```dart
class GetCurrentUserUseCase {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User?> call() => _repository.getCurrentUser();
}
```

### 3. Dependency Injection

```dart
class CreateThingBloc extends Bloc<SaveThingEvent, SaveThingState> {
  CreateThingBloc({requred this.repository}) : super(SaveThingState()) {
    on<SaveThingEvent>(_save);
  }

  final UserRepository repository; // Внедряется через DI

  Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
    final user = await repository.getCurrentUser();
    if (user != null) {
      await _repository.saveThing(userId: user.id, title: e.title);
    }
  }
}
```

## Проверка

- [ ] В UI/BLoC нет импортов `cloud_firestore`, `firebase_auth`, `sqflite`, `http` и т.п.
- [ ] Все обращения к данным идут через абстрактные интерфейсы
- [ ] Зависимости внедряются через конструктор (DI)
- [ ] UI только диспатчит события, не содержит бизнес-логики
- [ ] BLoC использует Repository/UseCase, не знает о конкретных источниках данных
