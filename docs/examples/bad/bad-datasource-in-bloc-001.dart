
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ❌ прямой источник
import 'package:firebase_auth/firebase_auth.dart';    // ❌ прямой источник

class SaveThingEvent {}
class SaveThingState {}

class CreateThingBloc extends Bloc<SaveThingEvent, SaveThingState> {
CreateThingBloc() : super(SaveThingState()) {
on<SaveThingEvent>(_save);
}

Future<void> _save(SaveThingEvent e, Emitter<SaveThingState> emit) async {
final uid = FirebaseAuth.instance.currentUser?.uid;              // ❌
if (uid == null) return;

await FirebaseFirestore.instance                                   // ❌
    .collection('item')
    .add({'userId': uid, 'title': 'New'});
}
}