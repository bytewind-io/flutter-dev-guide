part of 'thing_card_bloc.dart';

class ThingCardState with EquatableMixin {
  const ThingCardState({this.title = ''});

  final String title;

  @override
  List<Object?> get props => [title];
}
