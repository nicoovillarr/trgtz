import 'package:flutter/material.dart';

class MButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final double borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;

  const MButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 4.0,
    this.backgroundColor = const Color(0xFF003E4B),
    this.foregroundColor = Colors.white,
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
        child: Text(text),
      );
}
