import 'package:flutter/material.dart';

class MButton extends StatelessWidget {
  final Function() onPressed;
  final double borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final String? text;

  const MButton({
    super.key,
    required this.onPressed,
    this.borderRadius = 4.0,
    this.backgroundColor = const Color(0xFF003E4B),
    this.foregroundColor = Colors.white,
    this.child,
    this.text,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child ?? Text(text ?? ''),
      );
}
