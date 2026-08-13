import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/deck.dart';
import '../../shared/components/zen_button.dart';
import 'deck_viewmodel.dart';

class DeckForm extends StatefulWidget {
  const DeckForm({super.key});

  @override
  State<DeckForm> createState() => _DeckFormState();
}

class _DeckFormState extends State<DeckForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _frontController = TextEditingController(text: 'English');
  final _backController = TextEditingController(text: 'Vietnamese');

  void _save() {
    if (_formKey.currentState!.validate()) {
      final deck = Deck(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        languageFront: _frontController.text.trim(),
        languageBack: _backController.text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      context.read<DeckViewModel>().addDeck(deck);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Deck')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Deck Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _frontController,
                      decoration: const InputDecoration(labelText: 'Front Language', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _backController,
                      decoration: const InputDecoration(labelText: 'Back Language', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ZenButton(
                label: 'Save Deck',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
