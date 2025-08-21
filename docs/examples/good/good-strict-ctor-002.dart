// ✅ Строгий конструктор для nullable полей
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description, // nullable, но required
    required this.price,
    required this.category,
    required this.tags, // nullable, но required
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final ProductCategory category;
  final List<String>? tags;

  // ✅ Явно передаем null для nullable полей
  static Product createBasic(String id, String name, double price, ProductCategory category) {
    return Product(
      id: id,
      name: name,
      description: null, // ✅ явно null
      price: price,
      category: category,
      tags: null, // ✅ явно null
    );
  }
}
