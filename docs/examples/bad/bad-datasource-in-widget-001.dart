import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ❌ прямой источник
import 'package:firebase_auth/firebase_auth.dart';    // ❌ прямой источник

class CreateThingWidget extends StatefulWidget {
  const CreateThingWidget({super.key});

  @override
  State<CreateThingWidget> createState() => _CreateThingWidgetState();
}

class _CreateThingWidgetState extends State<CreateThingWidget> {
  final _titleController = TextEditingController();

  Future<void> _saveThing() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;              // ❌
    if (uid == null) return;

    await FirebaseFirestore.instance                                   // ❌
        .collection('item')
        .add({'userId': uid, 'title': _titleController.text});
        
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thing saved!')),
      );
    }
  }

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
            ElevatedButton(
              onPressed: _saveThing,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
