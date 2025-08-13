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
  CreateThingBloc(this._repo) : super(SaveThingState()) {
    on<SaveThingEvent>(_save);
  }
  final ThingRepository _repo; // ✅ зависимость от абстракции

  Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
    await _repo.saveThing(userId: e.userId, title: e.title); // ✅ без Firebase в BLoC
  }
}