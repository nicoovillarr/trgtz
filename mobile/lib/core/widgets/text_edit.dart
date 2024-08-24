import 'package:flutter/material.dart';

class TextEdit extends StatefulWidget {
  final String placeholder;
  final String? Function(String?)? validate;
  final void Function(String?)? onSaved;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;
  final bool isPassword;

  const TextEdit({
    super.key,
    required this.placeholder,
    this.validate,
    this.onSaved,
    this.initialValue = '',
    this.maxLines,
    this.maxLength,
    this.isPassword = false,
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
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFF455457),
            fontSize: 16.0,
          ),
          filled: true,
          fillColor: const Color(0xFFC0C0C0),
          focusedBorder: _buildBorder(const Color(0xFF003E4B)),
          errorBorder: _buildBorder(Colors.red),
          enabledBorder: _buildBorder(Colors.transparent),
          focusedErrorBorder: _buildBorder(Colors.redAccent),
        ),
        validator: widget.validate,
        onSaved: widget.onSaved,
      );

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2.0,
        ),
      );

  String get value => _key.currentState?.value ?? '';
}
