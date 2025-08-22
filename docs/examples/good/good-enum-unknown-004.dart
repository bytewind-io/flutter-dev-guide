// ✅ Обработка неизвестных значений
class DataProcessor {
  static void processItem(Item item) {
    final type = item.type;
    
    if (type == null) {
      // ✅ Явная обработка неизвестного типа
      print('Warning: Unknown item type, skipping processing');
      return;
    }
    
    switch (type) {
      case ItemType.book:
        print('Processing book...');
        break;
      case ItemType.movie:
        print('Processing movie...');
        break;
      case ItemType.music:
        print('Processing music...');
        break;
    }
  }
}
