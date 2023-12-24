import 'package:flutter/material.dart';
import 'package:mobile/models/index.dart';

class GoalsListView extends StatefulWidget {
  final List<Goal> goals;
  const GoalsListView({
    super.key,
    required this.goals,
  });

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.goals.length,
      itemBuilder: (ctx, idx) => ListTile(
        onTap: () => Navigator.of(ctx)
            .pushNamed('/goal', arguments: widget.goals[idx].goalID),
        title: Text(
          widget.goals[idx].title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
