// ✅ Строгий конструктор для enum полей
class Order {
  const Order({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.shippingAddress, // nullable, но required
  });

  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;
  final Address? shippingAddress;

  // ✅ Factory с явной передачей null
  factory Order.create(String id, List<OrderItem> items, double total) {
    return Order(
      id: id,
      status: OrderStatus.pending,
      items: items,
      total: total,
      shippingAddress: null, // ✅ явно null
    );
  }
}
