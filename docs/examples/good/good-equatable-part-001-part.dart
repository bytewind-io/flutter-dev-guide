part of 'thing_card_bloc.dart';

class ThingCardState extends Equatable {
  const ThingCardState({
    this.files = const [],
    this.type = '',
  });

  final List<Object> files;
  final String type;

  @override
  List<Object?> get props => [files, type];
}