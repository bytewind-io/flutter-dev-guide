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

class BasePaginationRequest {
  const BasePaginationRequest({
    required this.offset,
    required this.filterType,
  });

  final int offset;
  final FilterType? filterType; // ✅ enum в модели

  factory BasePaginationRequest.fromJson(Map<String, dynamic> json) {
    return BasePaginationRequest(
      offset: json['Offset'] as int,
      filterType: FilterType.fromValue(json['FilterType'] as int?),
    );
  }

  Map<String, dynamic> toJson() => {
        'Offset': offset,
        'FilterType': filterType?.value, // ✅ обратно в число
      };
}
