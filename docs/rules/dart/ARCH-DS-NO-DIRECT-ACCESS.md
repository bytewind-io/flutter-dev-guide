---
id: ARCH-DS-NO-DIRECT-ACCESS
title: "UI и BLoC не обращаются к Firebase/SQLite/HTTP напрямую"
status: stable
severity: error
category: architecture/boundaries
tags: [clean-architecture, repository, bloc, ui, datasource, firebase, sqlite, http]
linter_rule:
coverage: ai
bad_snippet: bad-datasource-in-bloc-001.dart
good_snippet: good-datasource-in-bloc-001.dart
references: []
ai_hint: >
  In lib/**/(ui|view|widget|bloc) forbid imports of cloud_firestore, firebase_auth, sqflite, isar, hive, http/dio etc.
  Flag any direct calls like FirebaseAuth.instance, FirebaseFirestore.instance, openDatabase, Dio().get, HttpClient().
  Suggest extracting a repository/gateway interface and inject it into the bloc/widget via DI. UI may dispatch events only.
---

## Пояснение

Слой **UI** (виджеты) и **BLoC** — это презентация/оркестрация. Они **не** знают о конкретных источниках данных (Firebase, SQLite, HTTP и т.п.) и **не** имеют от них зависимостей.  
Доступ к данным осуществляется через **интерфейсы** (Repository/Gateway/UseCase), реализованные в **infra/data** слое и подменяемые в тестах.

## Запрещено

- Импорты в UI/BLoC из `cloud_firestore`, `firebase_auth`, `sqflite`, `isar`, `hive`, `google_ml_kit`, `http`, `dio` и т.п.
- Прямые вызовы `FirebaseFirestore.instance...`, `FirebaseAuth.instance...`, `openDatabase(...)`, `Dio().get(...)`, `HttpClient()...`.

## Плохо (BLoC)
```dart
--8<-- "docs/examples/bad/bad-datasource-in-bloc-001.dart"
```

## Хорошо (BLoC)
```dart
--8<-- "docs/examples/good/good-datasource-in-bloc-001.dart"
```

## Плохо (UI Widget)
```dart
--8<-- "docs/examples/bad/bad-datasource-in-widget-001.dart"
```

## Хорошо (UI Widget)
```dart
--8<-- "docs/examples/good/good-datasource-in-widget-001.dart"
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
  CreateThingBloc(this._repository) : super(SaveThingState()) {
    on<SaveThingEvent>(_save);
  }
  
  final UserRepository _repository; // Внедряется через DI
  
  Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
    final user = await _repository.getCurrentUser();
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