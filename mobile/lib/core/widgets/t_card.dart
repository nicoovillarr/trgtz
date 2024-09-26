import 'package:flutter/material.dart';

class TCard extends StatelessWidget {
  final Widget child;
  final double contentPadding;
  final double borderRadius;
  final double elevation;
  const TCard({
    super.key,
    required this.child,
    this.contentPadding = 0.0,
    this.borderRadius = 16.0,
    this.elevation = 6.0,
  });

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        elevation: elevation,
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: EdgeInsets.all(contentPadding),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      );
}
