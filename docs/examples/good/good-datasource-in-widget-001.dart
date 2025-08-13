import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Абстракция уровня домена/репозитория
abstract class ThingRepository {
  Future<void> saveThing({required String userId, required String title});
}

// BLoC для управления состоянием
class CreateThingBloc extends Bloc<CreateThingEvent, CreateThingState> {
  CreateThingBloc(this._repository) : super(CreateThingInitial()) {
    on<CreateThingSubmitted>(_onSubmitted);
  }

  final ThingRepository _repository;

  Future<void> _onSubmitted(
    CreateThingSubmitted event,
    Emitter<CreateThingState> emit,
  ) async {
    emit(CreateThingLoading());
    try {
      await _repository.saveThing(
        userId: event.userId,
        title: event.title,
      );
      emit(CreateThingSuccess());
    } catch (error) {
      emit(CreateThingFailure(error.toString()));
    }
  }
}

// События
abstract class CreateThingEvent {}

class CreateThingSubmitted extends CreateThingEvent {
  CreateThingSubmitted({required this.userId, required this.title});
  final String userId;
  final String title;
}

// Состояния
abstract class CreateThingState {}

class CreateThingInitial extends CreateThingState {}
class CreateThingLoading extends CreateThingState {}
class CreateThingSuccess extends CreateThingState {}
class CreateThingFailure extends CreateThingState {
  CreateThingFailure(this.message);
  final String message;
}

// UI виджет - только отображение и диспатч событий
class CreateThingWidget extends StatelessWidget {
  const CreateThingWidget({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateThingBloc(
        context.read<ThingRepository>(), // Внедряется через DI
      ),
      child: BlocListener<CreateThingBloc, CreateThingState>(
        listener: (context, state) {
          if (state is CreateThingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thing saved!')),
            );
          } else if (state is CreateThingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: const _CreateThingForm(),
      ),
    );
  }
}

class _CreateThingForm extends StatefulWidget {
  const _CreateThingForm();

  @override
  State<_CreateThingForm> createState() => _CreateThingFormState();
}

class _CreateThingFormState extends State<_CreateThingForm> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Thing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CreateThingBloc, CreateThingState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is CreateThingLoading
                      ? null
                      : () {
                          context.read<CreateThingBloc>().add(
                                CreateThingSubmitted(
                                  userId: widget.userId,
                                  title: _titleController.text,
                                ),
                              );
                        },
                  child: state is CreateThingLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}