import 'package:injectable/injectable.dart';

abstract class MaxItemsRepositoryI {
  // ❌ НЕЛЬЗЯ: метод инициализации в репозитории
  Future<({bool isSpecial, int maxItems})> init(int initialValue);

  Future<void> updateIsSpecial(bool value);

  Future<void> submit({required int maxItems, required bool isSpecial});
}

@LazySingleton(as: MaxItemsRepositoryI)
class MaxItemsRepository implements MaxItemsRepositoryI {
  MaxItemsRepository({
    required BaseDataApiI baseDataApi,
    required MaxItemsApiI maxItemsApi,
  }) : _baseDataApi = baseDataApi,
       _maxItemsApi = maxItemsApi;

  final BaseDataApiI _baseDataApi;
  final MaxItemsApiI _maxItemsApi;

  @override
  Future<({bool isSpecial, int maxItems})> init(int initialValue) async {
    // ❌ Клиент вынужден позвать init() перед остальными методами
    final isSpecial = await _maxItemsApi.loadIsSpecial();
    return (isSpecial: isSpecial, maxItems: initialValue);
  }

  @override
  Future<void> updateIsSpecial(bool value) async {
    await _maxItemsApi.saveIsSpecial(value);
  }

  @override
  Future<void> submit({required int maxItems, required bool isSpecial}) async {
    final userId = await _baseDataApi.getCurrentUserUid();
    await _maxItemsApi.saveUserSettings(
      userId: userId,
      maxItems: maxItems,
      isSpecial: isSpecial,
    );
  }
}

// Пример зависимостей из data-слоя
abstract class BaseDataApiI {
  Future<String> getCurrentUserUid();
}

abstract class MaxItemsApiI {
  Future<bool> loadIsSpecial();

  Future<void> saveIsSpecial(bool value);

  Future<void> saveUserSettings({
    required String userId,
    required int maxItems,
    required bool isSpecial,
  });
}
