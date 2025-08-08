import 'package:equatable/equatable.dart';

enum FilterType { recent, popular }

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.filterType,
  });

  final int id;
  final String name;
  final String description;
  final FilterType? filterType;

  @override
  List<Object?> get props => [id, name, description, filterType];
}
