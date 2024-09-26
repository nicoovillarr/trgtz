import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NewGoalModal extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  String? _title;

  NewGoalModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create a new goal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Title',
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  _title = null;
                  return 'Title cannot be empty.';
                }
                _title = value;
                return null;
              },
            ),
            Expanded(child: Container()),
            ElevatedButton(
              onPressed: () {
                NavigatorState navigator = Navigator.of(context);
                if (_formKey.currentState!.validate() && navigator.canPop()) {
                  navigator.pop(_title);
                }
              },
              style: ElevatedButton.styleFrom(elevation: 5),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
