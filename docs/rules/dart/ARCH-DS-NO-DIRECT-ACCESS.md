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

# Проверяем только слой презентации: UI/BLoC/Cubit/Views/Widgets

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
- "lib/**/datasource/**"
- "lib/**/api/**"
- "lib/**/services/**"

# Явные нарушения: SDK источников данных и прямые вызовы клиентов

detect:
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

# SQL/NoSQL/ORM

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

# Чтобы не ловить ложные срабатывания, явно разрешаем утилиты потоков и инфраструктуру BLoC

allowlist_imports:

- "package:rxdart/rxdart.dart"
- "package:stream_transform/stream_transform.dart"
- "package:bloc_concurrency/bloc_concurrency.dart"
- "package:equatable/equatable.dart"
- "package:collection/collection.dart"
- "package:meta/meta.dart"
- "dart:async"

message: >
Слои UI/Presentation (включая BLoC/Cubit) не должны импортировать SDK источников данных
и не должны напрямую вызывать сетевые/БД/хранилищные API. Вынесите доступ к данным
за интерфейсы (Repository/Gateway/UseCase) в data/infra слой и внедряйте зависимости через DI.

autofix:

# Авто-фиксы ограничены безопасными текстовыми подсказками

suggestion_builder: minimal
suggestion: >
Создайте абстракцию (например, UserRepository/ThingRepository) и перенесите обращения
к {package-or-call} в infra слой. В BLoC внедрите интерфейс через конструктор (DI).

linter_rule:
coverage: ai

ai_hint: >
Флаг ставится ТОЛЬКО если файл относится к UI/Presentation/BLoC слоям (см. scope)
И при этом:
(1) есть import из deny-list (Firebase/HTTP/DB/Storage SDK),
ИЛИ (2) есть прямые вызовы из disallowed_calls.
Игнорируй любые импорты утилит потоков (rxdart, stream_transform, bloc_concurrency),
а также equatable/collection/meta — это не источники данных.
Если файл содержит 'part of', проанализируй владельца библиотеки перед проверкой импортов.
Не предлагай замену кода для RxDart — это вне области этого правила.

# Эти поля остаются для совместимости с репозиторием примеров

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

- path: "lib/module/home/bloc/home_bloc/home_bloc.dart"
  content: |
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:rxdart/rxdart.dart'; // ✅ допустимо
  typedef Evt<X> = EventTransformer<X>;
  Evt<E> debounceSwitchMap<E>(Duration d) =>
  (events, mapper) => events.debounceTime(d).switchMap(mapper);
  class HomeBloc extends Bloc<int, int> {
  HomeBloc(): super(0) {
  on<int>((e, emit) => emit(state + 1), transformer: debounceSwitchMap(const Duration(milliseconds:
  300)));
  }
  }
- path: "lib/feature/users/data/user_repository_impl.dart"
  content: |
  import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ допустимо: data слой
  class UserRepositoryImpl {
  final FirebaseFirestore _db;
  UserRepositoryImpl(this._db);
  Future<void> saveUser(String id) => _db.collection('users').doc(id).set({'id': id});
  }