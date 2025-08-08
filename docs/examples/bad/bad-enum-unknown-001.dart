enum ItemType {
  basic(0),
  premium(1); // ❌ нет unknown

  const ItemType(this.value);
  final int value;

  static ItemType fromValueOrUnknown(int? raw) {
    // ❌ Скрытая подмена на валидное значение
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    return ItemType.basic; // подмена
  }
}
