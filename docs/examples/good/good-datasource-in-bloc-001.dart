import 'package:bloc/bloc.dart';

// Абстракция уровня домена/репозитория
abstract class ThingRepository {
  Future<void> saveThing({required String userId, required String title});
}

class SaveThingEvent {
  SaveThingEvent(this.userId, this.title);
  final String userId;
  final String title;
}
class SaveThingState {}

class CreateThingBloc extends Bloc<SaveThingEvent, SaveThingState> {
  CreateThingBloc({required this.repo}) : super(SaveThingState()) {
    on<SaveThingEvent>(_save);
  }
  final ThingRepository _repository; // ✅ зависимость от абстракции

  Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
    await _repository.saveThing(userId: e.userId, title: e.title); // ✅ без Firebase в BLoC
  }
}