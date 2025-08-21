// ✅ Хороший подход: enum с unknown вариантом для non-null логики
enum ItemType {
  book(1),
  movie(2),
  music(3),
  unknown(-1); // ✅ Специальный вариант для неизвестных значений

  const ItemType(this.value);
  final int value;

  static ItemType fromValue(int? raw) {
    if (raw == null) return ItemType.unknown; // ✅ Возвращаем unknown вместо исключения
    
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    return ItemType.unknown; // ✅ Возвращаем unknown для неизвестных значений
  }
}
