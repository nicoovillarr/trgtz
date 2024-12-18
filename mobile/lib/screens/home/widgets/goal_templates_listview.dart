import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';

class GoalTemplate {
  final IconData icon;
  final String title;
  final String description;

  const GoalTemplate({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class GoalTemplatesListView extends StatelessWidget {
  final Function(GoalTemplate) onTemplateSelected;

  GoalTemplatesListView({
    super.key,
    required this.onTemplateSelected,
  });

  final List<GoalTemplate> templates = [
    GoalTemplate(
        icon: Icons.directions_run,
        title: 'Run 5k',
        description: 'Run 5 kilometers in one go'),
    GoalTemplate(
        icon: Icons.pool,
        title: 'Swim 1k',
        description: 'Swim 1 kilometer in one go'),
    GoalTemplate(
        icon: Icons.rocket,
        title:
            'Start a new habit',
        description: 'Start a new habit and stick to it'),
    GoalTemplate(
        icon: Icons.book,
        title: 'Read a book',
        description: 'Read a book in a month'),
  ];

  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: templates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
        itemBuilder: (context, index) {
          final template = templates[index];
          return ListTile(
            onTap: () => onTemplateSelected(template),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            tileColor: textButtonColor.withAlpha(10),
            title: RichText(
                text: TextSpan(
              children: [
                WidgetSpan(
                    child: Icon(
                  template.icon,
                  size: 18.0,
                )),
                WidgetSpan(child: SizedBox(width: 4.0)),
                TextSpan(
                    text: template.title,
                    style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ],
            )),
            subtitle: Text(template.description),
          );
        },
      );
}
