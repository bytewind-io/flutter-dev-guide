class ThingLocationModel {
  const ThingLocationModel({
    required this.uid,
    required this.name,
    required this.description,
    this.children = const [],
  });

  final String uid;
  final String name;
  final String description;
  final List<ThingLocationModel> children;

  // Factory для создания с временными данными
  factory ThingLocationModel.temp({
    String? uid,
    String? name,
    String? description,
    List<ThingLocationModel>? children,
  }) {
    return ThingLocationModel(
      uid: uid ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Temporary Location',
      description: description ?? 'Temporary description',
      children: children ?? const [],
    );
  }

  // Factory для создания с минимальными данными
  factory ThingLocationModel.minimal({
    required String name,
    String? description,
  }) {
    return ThingLocationModel(
      uid: 'gen_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description ?? 'No description provided',
      children: const [],
    );
  }

  // Factory для создания из JSON
  factory ThingLocationModel.fromJson(Map<String, dynamic> json) {
    return ThingLocationModel(
      uid: json['uid'] as String? ?? 'json_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Unknown Location',
      description: json['description'] as String? ?? 'No description',
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => ThingLocationModel.fromJson(child as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }
}
