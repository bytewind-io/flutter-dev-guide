// ✅ Factory для создания с временными данными
class Order {
  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime createdAt;

  // ✅ Factory для создания заказа в корзине
  factory Order.fromCart(List<OrderItem> items) {
    return Order(
      id: '', // будет заполнено при сохранении
      items: items,
      total: items.fold(0.0, (sum, item) => sum + item.price),
      createdAt: DateTime.now(),
    );
  }

  // ✅ Factory для создания из JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      total: json['total'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
