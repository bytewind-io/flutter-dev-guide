// ✅ Factory с валидацией
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  final String id;
  final String name;
  final double price;
  final ProductCategory category;

  // ✅ Factory с валидацией цены
  factory Product.create(String name, double price, ProductCategory category) {
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    
    return Product(
      id: _generateId(),
      name: name,
      price: price,
      category: category,
    );
  }

  static String _generateId() => 'prod_${DateTime.now().millisecondsSinceEpoch}';
}
