import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/core/base/index.dart';
import 'package:mobile/core/widgets/index.dart';
import 'package:mobile/models/index.dart';
import 'package:mobile/screens/home/widgets/index.dart';
import 'package:mobile/store/index.dart';
import 'package:mobile/store/local_storage.dart';
import 'package:mobile/utils.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreen<HomeScreen> {
  @override
  Widget body(BuildContext context) =>
      SingleChildScrollView(child: _buildBody());

  Widget _buildBody() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: _buildRows(),
          ),
        ),
      );

  List<Widget> _buildRows() => [
        _buildProgressBar(DateTime.now()),
        _buildStatsAndSelector(),
        _buildGoalsListView(),
      ];

  Widget _buildProgressBar(DateTime date) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            Utils.dateToFullString(date),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
        ),
        ProgressBar(date: date),
        const SizedBox(height: 16.0),
      ]);

  Widget _buildStatsAndSelector() => Row(
        children: [
          _buildPieCard(),
          _buildYearSelectorCard(),
        ],
      );

  Widget _buildPieCard() => SizedBox(
        width: 120,
        height: 120,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: StoreConnector<AppState, List<Goal>>(
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
                        colorList: const [
                          Color(0xFF98CE5A),
                          Color(0xFFE0E0E0),
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: StoreConnector<AppState, DateTime>(
              builder: (ctx, date) => SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildArrowButton(
                        () => StoreProvider.of<AppState>(context)
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
                        () => StoreProvider.of<AppState>(context)
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

  Widget _buildGoalsListView() => StoreConnector<AppState, AppState>(
        builder: (ctx, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Text(
              'Your goals for ${state.date.year}...',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF808080),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: GoalsListView(
                goals: state.goals
                    .where(
                        (g) => g.year == state.date.year && g.deletedOn == null)
                    .toList(),
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

  @override
  FloatingActionButton get fab => FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          simpleBottomSheet(
            title: 'New goal',
            child: TextEditModal(
              placeholder: 'I wanna...',
              maxLength: 50,
              maxLines: 1,
              validate: (title) => title != null && title.isNotEmpty
                  ? null
                  : 'Title cannot be empty',
              onSave: (s) {
                if (s != null && s.isNotEmpty) {
                  Store<AppState> store = StoreProvider.of<AppState>(context);
                  final newGoal = Goal(
                    goalID: const Uuid().v4(),
                    title: s,
                    year: store.state.date.year,
                    createdOn: DateTime.now(),
                    deletedOn: null,
                  );

                  store.dispatch(CreateGoalAction(goal: newGoal));
                  LocalStorage.saveGoals(store.state.goals);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('New goal created!'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'View',
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/goal', arguments: newGoal.goalID);
                        }),
                  ));
                }
              },
            ),
          );
        },
      );

  @override
  bool get addBackButton => false;
}
