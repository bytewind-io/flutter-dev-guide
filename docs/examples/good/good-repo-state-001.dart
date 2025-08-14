import 'package:injectable/injectable.dart';

/// Репозиторий: только операции данных — без init/setup и без управляемого состояния
abstract class MaxItemsRepositoryI {
  Future<bool> fetchIsSpecial(String userId);
  Future<void> saveIsSpecial(String userId, bool value);
  Future<MaxItemsSettings> loadSettings(String userId);
  Future<void> saveSettings(MaxItemsSettings settings);
}

class MaxItemsSettings {
  const MaxItemsSettings({required this.userId, required this.maxItems, required this.isSpecial});
  final String userId;
  final int maxItems;
  final bool isSpecial;

  MaxItemsSettings copyWith({int? maxItems, bool? isSpecial}) =>
      MaxItemsSettings(userId: userId, maxItems: maxItems ?? this.maxItems, isSpecial: isSpecial ?? this.isSpecial);
}

@LazySingleton(as: MaxItemsRepositoryI)
class MaxItemsRepository implements MaxItemsRepositoryI {
  MaxItemsRepository({required BaseDataApiI base, required MaxItemsApiI api})
      : _base = base,
        _api = api;

  final BaseDataApiI _base;
  final MaxItemsApiI _api;

  @override
  Future<bool> fetchIsSpecial(String userId) => _api.loadIsSpecial(userId);

  @override
  Future<void> saveIsSpecial(String userId, bool value) => _api.saveIsSpecial(userId, value);

  @override
  Future<MaxItemsSettings> loadSettings(String userId) => _api.loadUserSettings(userId);

  @override
  Future<void> saveSettings(MaxItemsSettings s) =>
      _api.saveUserSettings(userId: s.userId, maxItems: s.maxItems, isSpecial: s.isSpecial);
}

/// UseCase (над репозиторием): готовит данные для формы без init() в репозитории
class PrepareMaxItemsFormUseCase {
  PrepareMaxItemsFormUseCase(this._repo);

  final MaxItemsRepositoryI _repo;

  /// Вся «инициализация» — здесь: читаем isSpecial, комбинируем с initialValue
  Future<({bool isSpecial, int maxItems})> call({required String userId, required int initialValue}) async {
    final isSpecial = await _repo.fetchIsSpecial(userId);
    return (isSpecial: isSpecial, maxItems: initialValue);
  }
}

// Пример зависимостей data-слоя
abstract class BaseDataApiI {}
abstract class MaxItemsApiI {
  Future<bool> loadIsSpecial(String userId);
  Future<void> saveIsSpecial(String userId, bool value);
  Future<MaxItemsSettings> loadUserSettings(String userId);
  Future<void> saveUserSettings({required String userId, required int maxItems, required bool isSpecial});
}
