class ThingLocationModel {
  // ❌ Анти‑паттерн: nullable поля без factory конструкторов
  ThingLocationModel({
    this.uid,
    this.name,
    this.description,
  });

  String? uid;
  String? name;
  String? description;
  List<ThingLocationModel> children = []; // ❌ изменяемое поле

  // ❌ Анти‑паттерн: дублирование логики создания
  ThingLocationModel.temp() {
    uid = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    name = 'Temporary Location';
    description = 'Temporary description';
    children = [];
  }

  // ❌ Анти‑паттерн: еще один конструктор с дублированием
  ThingLocationModel.minimal(String name) {
    uid = 'gen_${DateTime.now().millisecondsSinceEpoch}';
    this.name = name;
    description = 'No description provided';
    children = [];
  }
}
