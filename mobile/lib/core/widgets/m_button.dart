import 'package:flutter/material.dart';

class MButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  const MButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: const Color(0xFF003E4B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: Text(text),
      );
}
