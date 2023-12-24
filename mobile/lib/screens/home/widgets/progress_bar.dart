import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProgressBar extends StatelessWidget {
  final double height = 32;
  final DateTime date;

  late double _percentage;

  ProgressBar({
    super.key,
    required this.date,
  }) {
    DateTime endYear = DateTime(date.year + 1).add(const Duration(days: -1));
    _percentage = _getDateMiliseconds(date) / _getDateMiliseconds(endYear);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double padding = 16.0;
    return SizedBox(
      height: height,
      width: size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            color: Color(0xFFBEBEBE),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                height: size.height,
                width: _percentage * (size.width - (padding * 2)),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003E4B), Color(0xFF00242C)],
                  ),
                ),
              ),
              Center(
                child: Text(
                  "${(_percentage * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDateMiliseconds(DateTime date) {
    return date.millisecondsSinceEpoch -
        DateTime(date.year).millisecondsSinceEpoch;
  }
}
