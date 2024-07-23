import 'package:flutter/material.dart';

class TCard extends StatelessWidget {
  final Widget child;
  final double contentPadding;
  const TCard({
    super.key,
    required this.child,
    this.contentPadding = 0.0,
  });

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.transparent,
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: EdgeInsets.all(contentPadding),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Material(
            child: child,
          ),
        ),
      );
}
