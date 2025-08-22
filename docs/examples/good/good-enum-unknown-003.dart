// ✅ Безопасный парсинг с null для неизвестных значений
enum OrderStatus {
  pending(0),
  confirmed(1),
  shipped(2),
  delivered(3);

  const OrderStatus(this.value);
  final int value;

  static OrderStatus? fromValue(int? raw) {
    if (raw == null) return null;
    
    for (final e in OrderStatus.values) {
      if (e.value == raw) return e;
    }
    return null; // ✅ null для неизвестных значений
  }
}

class Order {
  final String id;
  final OrderStatus? status; // nullable для неизвестных статусов

  const Order({required this.id, this.status});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: OrderStatus.fromValue(json['status'] as int?), // ✅ безопасно
    );
  }
}
