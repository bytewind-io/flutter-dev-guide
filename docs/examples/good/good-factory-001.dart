class User {
  const User({
    required this.id,
    required this.name,
    required this.age,
  });

  final int? id;
  final String name;
  final int? age;

  factory User.create({required String name, int? age}) {
    return User(id: null, name: name, age: age); // явный null
  }
}
