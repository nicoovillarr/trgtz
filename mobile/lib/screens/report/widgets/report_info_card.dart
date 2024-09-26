import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';

class ReportInfoCard extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? subtitle;
  const ReportInfoCard({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: mainColor,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) icon!,
                  if (title != null || subtitle != null)
                    const SizedBox(height: 8.0),
                  if (title != null) title!,
                  if (subtitle != null) subtitle!,
                ],
              ),
            ),
          ),
        ),
      );
}
