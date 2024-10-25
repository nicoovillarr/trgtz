import 'package:flutter/material.dart';

class ReportInfoField extends StatelessWidget {
  final String fieldName;
  final String value;
  const ReportInfoField({
    super.key,
    required this.fieldName,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$fieldName: ',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: value,
              ),
            ],
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
        ),
      );
}
