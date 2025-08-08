class BasePaginationRequest {
  const BasePaginationRequest({
    required this.offset,
    required this.filterType, // ❌ тип int?, должен быть enum?
  });

  final int offset;
  final int? filterType; // ❌

  factory BasePaginationRequest.fromJson(Map<String, dynamic> json) {
    return BasePaginationRequest(
      offset: json['Offset'] as int,
      filterType: json['FilterType'] as int?, // ❌ без парсинга в enum
    );
  }

  Map<String, dynamic> toJson() => {
        'Offset': offset,
        'FilterType': filterType?.toString(), // ❌ сериализация в строку
      };
}
