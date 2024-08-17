import 'package:flutter/material.dart';

class Dots extends StatelessWidget {
  final List<Widget> dots;
  final double size;
  final double spacingMultiplier;
  const Dots({
    super.key,
    required this.dots,
    this.size = 32.0,
    this.spacingMultiplier = 0.75,
  });

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.none,
        height: size,
        width: dots.length * size * spacingMultiplier +
            size * (1 - spacingMultiplier),
        child: Stack(
          children: [
            for (int i = 0; i < dots.length; i++)
              Positioned(
                left: i * size * spacingMultiplier,
                child: Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        spreadRadius: 2.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: dots[i],
                ),
              ),
          ],
        ),
      );

  static Widget _defaultBuilder(
          BuildContext context, int index, Widget child) =>
      child;
}
