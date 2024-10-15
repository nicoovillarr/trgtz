import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/home/widgets/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';

class DashboardFragment extends BaseFragment {
  const DashboardFragment({super.key, required super.enimtAction});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends BaseFragmentState<DashboardFragment> {
  bool sortAscending = false;
  late DateTime endYear;

  @override
  void customInitState() {
    endYear = DateTime(DateTime.now().year + 1).add(const Duration(days: -1));
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SeparatedColumn(
            spacing: 24.0,
            children: _buildRows(),
          ),
        ),
      );

  List<Widget> _buildRows() => [
        _buildProgressBar(DateTime.now()),
        _buildStatsAndSelector(),
        _buildAdsContainer(),
        _buildGoalsListView(),
      ];

  Widget _buildProgressBar(DateTime date) => Column(
        children: [
          Text(
            Utils.dateToFullString(date),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          ProgressBar(
            percentage:
                _getDateMiliseconds(date) / _getDateMiliseconds(endYear),
            addShadow: true,
          ),
        ],
      );

  Widget _buildStatsAndSelector() => Row(
        children: [
          _buildPieCard(),
          _buildYearSelectorCard(),
        ],
      );

  Widget _buildPieCard() => SizedBox(
        width: 120,
        height: 120,
        child: TCard(
          child: StoreConnector<ApplicationState, List<Goal>>(
            converter: (store) => store.state.goals
                .where((g) =>
                    g.year == store.state.date.year && g.deletedOn == null)
                .toList(),
            builder: (context, goals) => InkWell(
              onLongPress: () => _showStatsDialog(context, goals),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PieChart(
                        dataMap: {
                          "Completed":
                              Utils.getCompletedGoals(goals).length.toDouble(),
                          "ToDo": Utils.getToDoGoals(goals).length.toDouble(),
                        },
                        colorList: [
                          mainColor.withOpacity(0.85),
                          const Color(0xFFE0E0E0),
                        ],
                        legendOptions: const LegendOptions(showLegends: false),
                        chartValuesOptions:
                            const ChartValuesOptions(showChartValues: false),
                      ),
                    ),
                    Text(
                        "${Utils.getCompletedGoals(goals).length} / ${Utils.getToDoGoals(goals).length}"),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildYearSelectorCard() => Flexible(
        child: SizedBox(
          height: 120,
          child: TCard(
            child: StoreConnector<ApplicationState, DateTime>(
              builder: (ctx, date) => SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildArrowButton(
                        () => StoreProvider.of<ApplicationState>(context)
                            .dispatch(const AddDateYearAction(years: -1)),
                        false),
                    Text(
                      date.year.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildArrowButton(
                        () => StoreProvider.of<ApplicationState>(context)
                            .dispatch(const AddDateYearAction(years: 1)),
                        true),
                  ],
                ),
              ),
              converter: (store) => store.state.date,
            ),
          ),
        ),
      );

  Widget _buildAdsContainer() => const SizedBox(
        height: 100,
        width: double.infinity,
        child: BasicAdBanner(),
      );

  Widget _buildArrowButton(Function() onPressed, bool right) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        child: Icon(
          right ? Icons.arrow_right : Icons.arrow_left,
          size: 40,
          color: Colors.grey,
        ),
      );

  Widget _buildGoalsListView() =>
      StoreConnector<ApplicationState, ApplicationState>(
        builder: (ctx, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your goals for ${state.date.year}...',
                  style: const TextStyle(
                    color: Color(0xFF808080),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      setState(() => sortAscending = !sortAscending),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Sort by: ',
                          children: const [
                            TextSpan(
                              text: 'status',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            color: textButtonColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        turns: sortAscending ? 0 : -0.5,
                        curve: Curves.easeInOut,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: textButtonColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TCard(
              child: GoalsListView(
                goals: Utils.sortGoals(
                  state.goals
                      .where((g) =>
                          g.year == state.date.year && g.deletedOn == null)
                      .toList(),
                  ascending: sortAscending,
                ),
              ),
            ),
          ],
        ),
        converter: (store) => store.state,
      );

  void _showStatsDialog(BuildContext context, List<Goal> goals) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Your goals:'),
            content: Wrap(
              direction: Axis.vertical,
              children: [
                Text("Completed: ${Utils.getCompletedGoals(goals).length}"),
                Text("To Do: ${Utils.getToDoGoals(goals).length}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'),
              ),
            ],
          ));

  int _getDateMiliseconds(DateTime date) {
    return date.millisecondsSinceEpoch -
        DateTime(date.year).millisecondsSinceEpoch;
  }
}
