// ✅ Создание enum с числовыми значениями
enum OrderStatus {
  pending(0),
  confirmed(1),
  shipped(2),
  delivered(3),
  cancelled(4);

  const OrderStatus(this.value);
  final int value;

  static OrderStatus? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in OrderStatus.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}
