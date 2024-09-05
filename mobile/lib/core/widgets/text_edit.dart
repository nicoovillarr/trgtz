import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';

class TextEdit extends StatefulWidget {
  final String placeholder;
  final String? Function(String?)? validate;
  final void Function(String?)? onSaved;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;
  final bool isPassword;
  final bool showMaxLength;

  const TextEdit({
    super.key,
    required this.placeholder,
    this.validate,
    this.onSaved,
    this.initialValue = '',
    this.maxLines,
    this.maxLength,
    this.isPassword = false,
    this.showMaxLength = true,
  });

  @override
  State<TextEdit> createState() => TextEditState();
}

class TextEditState extends State<TextEdit> {
  final GlobalKey<FormFieldState<String>> _key =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
          fillColor: mainColor.withOpacity(0.2),
          focusedBorder: _buildBorder(const Color(0xFF003E4B)),
          errorBorder: _buildBorder(Colors.red),
          enabledBorder: _buildBorder(Colors.transparent),
          focusedErrorBorder: _buildBorder(Colors.redAccent),
          counterText: widget.showMaxLength ? null : '',
        ),
        validator: widget.validate,
        focusNode: _focusNode,
        autofocus: false,
        onSaved: widget.onSaved,
        onTapOutside: (_) => _focusNode.unfocus(),
      );

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2.0,
        ),
      );

  String get value => _key.currentState?.value ?? '';
}
