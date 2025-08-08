class TaskModel {
  const TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.filterType,
  });

  final int id;
  final String name;
  final String description;
  final int? filterType; // ❌ должен быть enum?
}

// ❌ Сравнение по ссылке: два одинаковых по значениям экземпляра не равны.
