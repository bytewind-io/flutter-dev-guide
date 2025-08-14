import 'package:flutter/foundation.dart';

class PlacesRepo {
  PlacesRepo(this.placeApi, this.placeDao);
  final PlaceApi placeApi;
  final PlaceDao placeDao;

  void start() {
    /* PlaceAtributeUpdater(placeApi: placeApi, placeDao: placeDao)
        .getCompanyAtributes(
            placeSubject!.stream.map((event) => event.placesList))
        .asyncMap((states) async {
      await placeDao.saveCompanyState(states);
      return states;
    }).listen((event) {
      updatePlaces(event.map((e) => e.id).toList());
    }, onError: (dynamic e, StackTrace s) {
      print(e);
      print(s);
    });*/ // ❌ Мёртвый закомментированный код
  }

  Future<List<AreaModel>> getAreas() async {
    final areasFromDb = await placeDao.getAreas();
    debugPrint('@@@ areasFromDb.length=$areasFromDb'); // ❌ отладочный шум в проде

    if (areasFromDb.isNotEmpty) {
      return areasFromDb;
    }
    final list = (await placeApi.getAreas()).areas;
    await placeDao.saveAreas(list);
    debugPrint('@@@ areasFromDb list=$list'); // ❌
    return list;
  }
}

// Вспомогательные типы для примера
class PlaceApi { Future<AreasResponse> getAreas() async => AreasResponse([]); }
class PlaceDao {
  Future<List<AreaModel>> getAreas() async => [];
  Future<void> saveAreas(List<AreaModel> list) async {}
}
class AreasResponse { AreasResponse(this.areas); final List<AreaModel> areas; }
class AreaModel { AreaModel(this.id); final String id; }
