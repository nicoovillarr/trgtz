import 'package:flutter/cupertino.dart';

class SeparatedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  const SeparatedColumn({
    super.key,
    this.children = const [],
    this.spacing = 8.0,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding:
                EdgeInsets.only(bottom: i < children.length - 1 ? spacing : 0),
            child: children[i],
          ),
      ],
    );
  }
}
