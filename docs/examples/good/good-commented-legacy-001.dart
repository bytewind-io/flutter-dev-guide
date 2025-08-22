import 'package:flutter/foundation.dart';

class PlacesRepo {
  PlacesRepo(this.placeApi, this.placeDao);
  final PlaceApi placeApi;
  final PlaceDao placeDao;

  /// Репозиторий не содержит закомментированного кода — альтернативы ищите в истории Git/ADR.
  void start() {
    // Ничего не комментируем — удаляем мёртвый код.
  }

  Future<List<AreaModel>> getAreas() async {
    final cached = await placeDao.getAreas();
    if (cached.isNotEmpty) return cached;

    final list = (await placeApi.getAreas()).areas;
    await placeDao.saveAreas(list);
    return list;
  }
}

// Обсуждение альтернативного pipe-а в документации

// Вспомогательные типы для примера
class PlaceApi { Future<AreasResponse> getAreas() async => AreasResponse([]); }
class PlaceDao {
  Future<List<AreaModel>> getAreas() async => [];
  Future<void> saveAreas(List<AreaModel> list) async {}
}
class AreasResponse { AreasResponse(this.areas); final List<AreaModel> areas; }
class AreaModel { AreaModel(this.id); final String id; }
