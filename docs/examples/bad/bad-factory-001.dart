class User {
  const User({
    this.id,
    required this.name,
    this.age,
  });

  final int? id;
  final String name;
  final int? age;

  // ❌ Анти‑паттерн: «сентинел» вместо явного null
  factory User.temp({required String name, int? age}) {
    return User(id: -1, name: name, age: age); // -1 как псевдо-null
  }
}
