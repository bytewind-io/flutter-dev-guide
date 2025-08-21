// ✅ Использование enum в модели
class Order {
  final String id;
  final OrderStatus status;

  const Order({required this.id, required this.status});

  bool get isCompleted => status == OrderStatus.delivered;
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: OrderStatus.fromValue(json['status'] as int?) ?? OrderStatus.pending,
    );
  }
}
