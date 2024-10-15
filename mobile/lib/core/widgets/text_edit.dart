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
  final bool enabled;

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
    this.enabled = true,
  });

  @override
  State<TextEdit> createState() => TextEditState();
}

class TextEditState extends State<TextEdit> {
  final GlobalKey<FormFieldState<String>> _key =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _errorText;

  String get value => _key.currentState?.value ?? '';

  set errorText(String value) => setState(() => _errorText = value);

  @override
  void initState() {
    super.initState();
    _controller.value = TextEditingValue(text: widget.initialValue ?? '');
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    duration: const Duration(milliseconds: 200),
    child: TextFormField(
          key: _key,
          controller: _controller,
          keyboardType: TextInputType.multiline,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          obscureText: widget.isPassword,
          enabled: widget.enabled,
          decoration: InputDecoration(
            isDense: true,
            errorText: _errorText,
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
            disabledBorder: _buildBorder(Colors.transparent),
            focusedErrorBorder: _buildBorder(Colors.redAccent),
            counterText: widget.showMaxLength ? null : '',
          ),
          validator: widget.validate,
          focusNode: _focusNode,
          autofocus: false,
          onSaved: widget.onSaved,
          onTapOutside: (_) => unfocus(),
        ),
  );

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2.0,
        ),
      );

  void unfocus() => _focusNode.unfocus();

  void save() {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
    }
  }

  void clear() => _controller.clear();

  void addError(String message) => setState(() {
        _errorText = message;
      });
}
