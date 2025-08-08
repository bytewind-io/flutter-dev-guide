class User {
  const User({
    this.id,              // ❌ не required
    this.name,            // ❌ не required
    this.age,             // ❌ не required
  });

  final int? id;
  final String? name;
  final int? age;
}
