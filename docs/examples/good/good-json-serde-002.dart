// ✅ Создание enum с числовыми значениями
enum Status {
  pending(0),
  active(1),
  completed(2),
  cancelled(3);

  const Status(this.value);
  final int value;

  static Status? fromValue(int? raw) {
    if (raw == null) return null;
    for (final e in Status.values) {
      if (e.value == raw) return e;
    }
    return null;
  }
}
