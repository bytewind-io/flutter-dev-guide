// ❌ Магические числа «протекают» в модель
class Request {
  const Request({required this.filterType});
  final int? filterType;
}

// ❌ Небезопасный парсер: бросит StateError при неизвестном значении
enum FilterType {
  recent(1),
  popular(2);

  const FilterType(this.value);
  final int value;

  static FilterType fromValue(int raw) =>
      FilterType.values.firstWhere((e) => e.value == raw);
}
