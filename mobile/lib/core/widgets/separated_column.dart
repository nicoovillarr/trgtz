import 'package:flutter/material.dart';

class SeparatedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool addDivider;
  const SeparatedColumn({
    super.key,
    this.children = const [],
    this.spacing = 8.0,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.addDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...buildChild(context, i),
      ],
    );
  }

  List<Widget> buildChild(BuildContext context, int index) => [
        Padding(
          padding: EdgeInsets.only(
              bottom: index < children.length - 1 && !addDivider ? spacing : 0),
          child: children[index],
        ),
        if (addDivider && index < children.length - 1)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing / 2),
            child: const Divider(),
          ),
      ];
}
