Документация по работе с дата-классами

1. Строгий конструктор:
-	Все поля делаем required, даже если они могут быть null.
-	Это заставляет явно указывать null при создании объекта.

Пример:

```
class User {
  const User({
    required this.id,
    required this.name,
    required this.age,
  });

  final int id;
  final String name;
  final int? age;
}
```

Также при создании таких классов (с null полями) рекомендуется использовать **factory**

Пример:

```
class User {
  const User({
    required this.id,
    required this.name,
    required this.age,
  });

factory User.create({required String name, required int age}){
  return User(
       id: null,
       name: name,
       age: age,
   );
}

  final int id;
  final String name;
  final int? age;
}
```

------------

2. Enum вместо «магических» чисел
- Все поля вроде filterType, type при fromJson преобразуем в enum.
- Enum содержит все возможные значения.
- В enum должен быть static метод fromValue, который возвращает null, если нет совпадения.

Пример enum с nullable результатом:

```
import 'package:collection/collection.dart';

enum FilterType {
  recent(1),
  popular(2);

  const FilterType(this.value);
  final int value;

  static FilterType? fromValue(int? raw) {
    if (raw == null) return null;
    return FilterType.values.firstWhereOrNull((e) => e.value == raw);
  }
}
```

------------

3. Если fromValue вернул null

Есть два подхода:
1. Оставить null — рекомендуемый вариант.
2. Добавить в enum значение unknown и возвращать его.

Пример с unknown:

```
enum ItemType {
  basic(0),
  premium(1),
  unknown(-1);

  const ItemType(this.value);
  final int value;

  static ItemType fromValueOrUnknown(int? raw) {
    return values.firstWhereOrNull(
      (e) => e.value == raw
    ) ?? ItemType.unknown;
  }
}
```

------------

4. Пример fromJson / toJson

```
class BasePaginationRequest {
  const BasePaginationRequest({
    required this.offset,
    required this.filterType,
  });

  final int offset;
  final FilterType? filterType;

  factory BasePaginationRequest.fromJson(Map<String, dynamic> json) {
    return BasePaginationRequest(
      offset: json['Offset'] as int,
      filterType: FilterType.fromValue(json['FilterType'] as int?),
    );
  }

  Map<String, dynamic> toJson() => {
        'Offset': offset,
        'FilterType': filterType?.value,
      };
}
```

------------

5. Модель должна наслкдоваться от Equatable


Пример модели:

```
class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.filterType,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      filterType: FilterType.fromValue(json['filterType'] as int?),
    );
  }

  final int id;
  final String name;
  final String description;
  final FilterType? filterType;

  @override
  List<Object?> get props => [id, name, description, filterType];
}
```
