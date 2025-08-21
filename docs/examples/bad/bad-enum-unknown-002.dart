// ❌ Плохой подход: enum без unknown варианта, но требующий non-null
enum ItemType {
  book(1),
  movie(2),
  music(3);

  const ItemType(this.value);
  final int value;

  static ItemType fromValue(int? raw) {
    if (raw == null) {
      // ❌ Выбрасываем исключение вместо возврата unknown
      throw ArgumentError('ItemType cannot be null');
    }
    
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    
    // ❌ Выбрасываем исключение для неизвестных значений
    throw ArgumentError('Unknown ItemType: $raw');
  }
}
