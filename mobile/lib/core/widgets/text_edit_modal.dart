import 'package:flutter/material.dart';
import 'package:trgtz/core/widgets/index.dart';

final _formKey = GlobalKey<FormState>();
final _textEditKey = GlobalKey<TextEditState>();

// ignore: must_be_immutable
class TextEditModal extends StatelessWidget {
  final String placeholder;
  final Function(String?) onSave;
  final String? Function(String?)? validate;
  final String buttonText;
  String? initialValue;
  int? maxLines;
  int? maxLength;

  TextEditModal({
    super.key,
    required this.placeholder,
    required this.onSave,
    this.buttonText = 'Save',
    this.validate,
    this.initialValue = '',
    this.maxLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextEdit(
              key: _textEditKey,
              placeholder: placeholder,
              initialValue: initialValue,
              maxLines: maxLines,
              maxLength: maxLength,
              validate: validate,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigatorState navigator = Navigator.of(context);
                if (_formKey.currentState!.validate() && navigator.canPop()) {
                  onSave(_textEditKey.currentState!.value);
                  navigator.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: const Color(0xFF003E4B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
