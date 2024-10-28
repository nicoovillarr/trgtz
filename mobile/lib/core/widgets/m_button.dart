import 'package:flutter/material.dart';

enum MButtonType {
  primary,
  secondary,
}

class MButton extends StatelessWidget {
  final Function() onPressed;
  final double borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final Widget? leading;
  final String? text;
  final MButtonType type;
  final bool outlined;

  const MButton({
    super.key,
    required this.onPressed,
    this.borderRadius = 4.0,
    this.backgroundColor = const Color(0xFF003E4B),
    this.foregroundColor = Colors.white,
    this.child,
    this.text,
    this.type = MButtonType.primary,
    this.outlined = false,
    this.leading,
  });

  ButtonStyle get _primaryStyle => ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );

  ButtonStyle get _secondaryStyle => ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: Colors.white,
        foregroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );

  ButtonStyle get _style =>
      type == MButtonType.primary ? _primaryStyle : _secondaryStyle;

  Widget get _child => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading!,
          if (leading != null) const SizedBox(width: 8),
          child ?? Text(text ?? ''),
        ],
      );

  @override
  Widget build(BuildContext context) => !outlined
      ? ElevatedButton(
          onPressed: onPressed,
          style: _style,
          child: _child,
        )
      : OutlinedButton(
          onPressed: onPressed,
          style: _style,
          child: _child,
        );
}
