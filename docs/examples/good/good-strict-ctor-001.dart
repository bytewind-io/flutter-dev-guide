class User {
  const User({
    required this.id,     // ✅ даже если nullable — передаём явно
    required this.name,
    required this.age,
  });

  final int? id;
  final String name;
  final int? age;
}

// Пример создания (явно передаём null где нужно):
final u = User(id: null, name: 'Alice', age: null);
