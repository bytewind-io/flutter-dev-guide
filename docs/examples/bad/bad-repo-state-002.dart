import 'dart:io';
import 'package:injectable/injectable.dart';
import '../model/things_model.dart';
import '../network/base_data_api.dart';

@LazySingleton(as: ThingsRepositoryI)
class ThingsRepository implements ThingsRepositoryI {
  ThingsRepository({required BaseDataApiI baseDataApi}) : _baseDataApi = baseDataApi;

  final BaseDataApiI _baseDataApi;

  @override
  Stream<List<ThingsModel>> fetchMyThings() {           // ❌ Stream в публичном API репозитория
    return _baseDataApi.fetchAllThings();
  }

  @override
  Future<List<ThingsModel>> fetchMyThingsOnce() {       // ❌ дублирующий once-вариант
    return _baseDataApi.fetchAllThings().first;
  }

  @override
  Future<void> deleteThingsByType(String type) async {  // ❌ избыточное имя
    return _baseDataApi.deleteThingsByType(type);
  }

  @override
  Future<List<String>> uploadImages(List<File> images) async { // ❌ не относится к ThingsRepository (сквозной сервис)
    return _baseDataApi.uploadImages(images);
  }

  @override
  Future<void> deleteItemByUid(String uid) async {      // ❌ имя не согласовано (Item vs Thing)
    return _baseDataApi.deleteItemByUid(uid);
  }

  @override
  Stream<List<ThingsModel>> searchThingsByTitle(String searchQuery) { // ❌ Stream + длинное имя
    return _baseDataApi.searchThingsByTitle(searchQuery);
  }

  @override
  Future<void> deleteItemsByUids(List<String> uids) async {
    return _baseDataApi.deleteItemsByUids(uids);
  }

  @override
  void dispose() {                                      // ✅ в классе последний, но
    // No longer needed
  }
}

// ❌ В интерфейсе dispose() не последний и лишние стрим-методы
abstract class ThingsRepositoryI {
  void dispose();  // ❌ должен быть последним

  Stream<List<ThingsModel>> fetchMyThings();                 // ❌ Stream
  Future<List<ThingsModel>> fetchMyThingsOnce();             // ❌ избыточно
  Future<void> deleteThingsByType(String type);              // ❌ длинно
  Future<void> deleteItemByUid(String uid);
  Future<void> deleteItemsByUids(List<String> uids);
  Stream<List<ThingsModel>> searchThingsByTitle(String searchQuery); // ❌ Stream + длинно
  Future<List<String>> uploadImages(List<File> images);      // ❌ не по ответственности
}
