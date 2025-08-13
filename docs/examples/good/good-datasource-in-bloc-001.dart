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
  CreateThingBloc({required this.repository}) : super(SaveThingState()) {
    on<SaveThingEvent>(_save);
  }
  final ThingRepository repository; // ✅ зависимость от абстракции

  Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
    await repository.saveThing(userId: e.userId, title: e.title); // ✅ без Firebase в BLoC
  }
}