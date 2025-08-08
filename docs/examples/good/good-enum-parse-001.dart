enum FilterType {
  recent(1),
  popular(2);

  const FilterType(this.value);
  final int value;

  static FilterType? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in FilterType.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}

class Request {
  const Request({required this.filterType});
  final FilterType? filterType; // ✅ enum в модели
}
