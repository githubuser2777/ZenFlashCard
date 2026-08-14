import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/flashcard.dart';
import '../../shared/components/zen_button.dart';
import 'card_viewmodel.dart';

class CardForm extends StatefulWidget {
  final String deckId;

  const CardForm({super.key, required this.deckId});

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  bool _isChecking = false;

  void _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      setState(() => _isChecking = true);
      
      final cardVM = context.read<CardViewModel>();
      final front = _frontController.text.trim();
      final back = _backController.text.trim();

      final isDuplicate = await cardVM.checkDuplicate(widget.deckId, front, back);
      
      if (!mounted) return;
      setState(() => _isChecking = false);

      if (isDuplicate) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Duplicate Card'),
            content: const Text('This exact card already exists in this deck. Add anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
            ],
          ),
        );
        if (confirm != true) return;
      }

      final card = Flashcard(
        id: const Uuid().v4(),
        deckId: widget.deckId,
        front: front,
        back: back,
        nextReview: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await cardVM.addCard(card);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _frontController,
                decoration: const InputDecoration(labelText: 'Front (Word)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(labelText: 'Back (Meaning)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _isChecking
                  ? const Center(child: CircularProgressIndicator())
                  : ZenButton(
                      label: 'Save Card',
                      onPressed: _save,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
