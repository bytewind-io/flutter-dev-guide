enum ItemType {
  basic(0),
  premium(1),
  unknown(-1);

  const ItemType(this.value);
  final int value;

  static ItemType fromValueOrUnknown(int? raw) {
    if (raw == null) return ItemType.unknown;
    for (final e in ItemType.values) {
      if (e.value == raw) return e;
    }
    return ItemType.unknown;
  }
}
