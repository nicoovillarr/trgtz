import 'package:flutter/material.dart';

class TextEdit extends StatefulWidget {
  final String placeholder;
  final String? Function(String?)? validate;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;

  const TextEdit({
    super.key,
    required this.placeholder,
    this.validate,
    this.initialValue = '',
    this.maxLines,
    this.maxLength,
  });

  @override
  State<TextEdit> createState() => TextEditState();
}

class TextEditState extends State<TextEdit> {
  final GlobalKey<FormFieldState<String>> _key =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.value = TextEditingValue(text: widget.initialValue ?? '');
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        key: _key,
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          hintText: widget.placeholder,
          filled: true,
          fillColor: Colors.grey[150],
          focusedBorder: _buildBorder(const Color(0xFF003E4B)),
          errorBorder: _buildBorder(Colors.red),
          enabledBorder: _buildBorder(const Color.fromARGB(123, 158, 158, 158)),
          focusedErrorBorder: _buildBorder(Colors.redAccent),
        ),
        validator: widget.validate,
      );

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2.0,
        ),
      );

  String get value => _key.currentState?.value ?? '';
}
