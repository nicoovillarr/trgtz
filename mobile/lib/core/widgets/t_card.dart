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
        color: Colors.white,
        elevation: 6,
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(contentPadding),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.none,
            child: child,
          ),
        ),
      );
}
