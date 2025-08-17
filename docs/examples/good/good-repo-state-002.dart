import 'package:injectable/injectable.dart';
import '../model/things_model.dart';
import '../network/base_data_api.dart';

/// Фильтры выборки — расширяемые и типобезопасные
sealed class FetchFilter {
  const FetchFilter();
}
class EmptyFilter extends FetchFilter {
  const EmptyFilter();
}
class IdsFilter extends FetchFilter {
  const IdsFilter(this.ids);
  final List<String> ids;
}
class TextFilter extends FetchFilter {
  const TextFilter(this.text);
  final String text;
}

@LazySingleton(as: ThingsRepositoryI)
class ThingsRepository implements ThingsRepositoryI {
  ThingsRepository({required BaseDataApiI base}) : _base = base;

  final BaseDataApiI _base;

  @override
  Stream<List<ThingsModel>> fetch(FetchFilter filter) {
    return switch (filter) {
      EmptyFilter() => _baseDataApi.fetchAllThings(),
      IdsFilter(ids: final ids) => _baseDataApi.fetchAllThings().map(
            (things) =>
            things.where((thing) => ids.contains(thing.id)).toList(),
      ),
      TextSearchFilter(text: final type) => _baseDataApi.search(type),
    };
  }


  @override
  Future<void> deleteByType(String type) => _base.deleteByType(type);

  @override
  Future<void> deleteByUid(String uid) => _base.deleteByUid(uid);

  @override
  Future<void> deleteByUids(List<String> uids) => _base.deleteByUids(uids);

  @override
  void dispose() {
    // при необходимости освободить ресурсы репозитория
  }
}

// Интерфейс в конце файла; dispose() — последним методом
abstract class ThingsRepositoryI {
  Future<List<ThingsModel>> fetch(FetchFilter filter);
  Future<void> deleteByType(String type);
  Future<void> deleteByUid(String uid);
  Future<void> deleteByUids(List<String> uids);

  void dispose();
}
