import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double? size;
  final String? text;
  const Separator({
    super.key,
    this.size,
    this.text,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                text != null ? _separatorWithText() : [_singleSeparator()],
          ),
        ),
      );

  Widget _singleSeparator() => Flexible(
        child: Container(
          height: 1,
          color: color,
        ),
      );

  List<Widget> _separatorWithText() => [
        _singleSeparator(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text!,
            style: TextStyle(
              color: color,
              fontSize: 10.0,
            ),
          ),
        ),
        _singleSeparator(),
      ];

  Color get color => const Color(0xFF7BA4AD);
}
