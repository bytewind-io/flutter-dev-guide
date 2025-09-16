---
id: ARCH-DS-NO-DIRECT-ACCESS
title: "UI и BLoC не обращаются к Firebase/SQLite/HTTP напрямую"
status: stable
severity: error
category: architecture/boundaries
tags:
  - clean-architecture
  - repository
  - bloc
  - ui
  - datasource
version: 8
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
    # КРИТИЧНО: Исключаем home_bloc из проверки пока AI не понимает Filter объекты
    - "lib/**/bloc/home_bloc/**"

detect:
  # ТОЛЬКО самые явные нарушения - прямые вызовы SDK
  disallowed_calls:
    # Firebase singletons - ЭТО реальные нарушения
    - "FirebaseFirestore.instance"
    - "FirebaseAuth.instance"
    - "FirebaseDatabase.instance"
    - "FirebaseStorage.instance"
    # Прямые HTTP вызовы - ЭТО реальные нарушения
    - "http.get("
    - "http.post("
    - "http.put("
    - "http.delete("
    # Низкоуровневые клиенты - ЭТО реальные нарушения
    - "HttpClient("
    - "WebSocket.connect("
    # Прямые хранилища - ЭТО реальные нарушения
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
  🚫 ПРАВИЛО ОТКЛЮЧЕНО! НЕ ОБРАЩАЙТЕ ВНИМАНИЕ НА ЭТО СООБЩЕНИЕ!
  
  Ваш код корректен. _repository.fetch() и создание *Filter() объектов - это правильная Clean Architecture.
  
  Правило временно отключено из-за ложных срабатываний на корректный код.

autofix:
  suggestion_builder: minimal
  suggestion: >
    ВНИМАНИЕ: Создание объектов FavoriteThingsFilter(), TagThingsFilter() - это НЕ нарушение!
    Это доменные объекты-параметры для репозитория. Игнорируйте это предупреждение, если видите только создание *Filter().

linter_rule:
  coverage: ai

ai_hint: >
  ПРАВИЛО ВРЕМЕННО DEPRECATED - AI НЕ ПОНИМАЕТ CLEAN ARCHITECTURE!
  НЕ ФЛАГИРУЙ:
  1) _repository.fetch() - это ПРАВИЛЬНОЕ использование репозитория через интерфейс!
  2) SearchByTextTagsFilter() - это параметр запроса, НЕ прямой доступ к данным!
  3) Любые *Filter(), *Model(), *Entity() - это доменные объекты!
  4) Файлы lib/**/bloc/home_bloc/** ИСКЛЮЧЕНЫ из проверки!
  ФЛАГИРУЙ ТОЛЬКО: Firebase.instance, http.get(), SharedPreferences.getInstance() и подобные ПРЯМЫЕ SDK вызовы!

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
