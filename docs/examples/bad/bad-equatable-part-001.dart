part of 'thing_card_bloc.dart';

class ThingCardState {
  const ThingCardState({
    this.files = const [],
    this.type = '',
  });

  final List<Object> files;
  final String type;

  // ❌ Нет extends Equatable/EquatableMixin и нет props — сравнение по ссылке
}
