import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class ProgressBar extends StatelessWidget {
  final double height;
  final double percentage;
  final double cornerRadius;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.percentage,
    this.height = 32.0,
    this.cornerRadius = 24.0,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: height,
      width: size.width,
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
            color: const Color(0xFFBEBEBE),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: size.height,
                width: percentage * constraints.maxWidth,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF003E4B), Color(0xFF00242C)],
                  ),
                ),
              ),
              if (showPercentage)
                Center(
                  child: Text(
                    "${(percentage * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
