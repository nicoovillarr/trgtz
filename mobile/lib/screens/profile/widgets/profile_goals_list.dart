import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trgtz/models/index.dart';

class ProfileGoalsList extends StatelessWidget {
  final List<Goal> goals;
  final Axis direction;
  const ProfileGoalsList({
    super.key,
    required this.goals,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: direction,
        child: direction == Axis.horizontal
            ? _buildHorizontalList()
            : _buildVerticalList(),
      );

  Widget _buildHorizontalList() => Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < goals.length; i++)
                _buildGoalCard(
                  goals[i],
                  constraints: const BoxConstraints(
                    minWidth: 120,
                    maxWidth: 300,
                  ),
                ),
            ],
          ),
        ],
      );

  Widget _buildVerticalList() => Column(
        children: [
          for (int i = 0; i < goals.length; i++) _buildGoalCard(goals[i]),
        ],
      );

  Widget _buildGoalCard(Goal goal, {BoxConstraints? constraints}) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: goal.completedOn != null ? 0.5 : 1,
          child: Card(
            color: Colors.white,
            elevation: 5,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {},
              child: Container(
                constraints: constraints,
                child: ListTile(
                  title: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: goal.description != null
                      ? Text(
                          goal.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff606060),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );

  static Widget placeholder({int count = 5, Axis direction = Axis.vertical}) =>
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: direction,
        child: direction == Axis.horizontal
            ? Row(
                children: [
                  for (int i = 0; i < count; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 16.0,
                        right: i < count - 1 ? 16.0 : 0,
                        left: i == 0 ? 16.0 : 0,
                      ),
                      child: Opacity(
                        opacity: (count - i) / count,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 80,
                            width: Random().nextInt(101) + 200,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < count; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: i < count - 1 ? 16.0 : 0,
                        top: i == 0 ? 16.0 : 0,
                      ),
                      child: Opacity(
                        opacity: (count - i) / count,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
      );
}
