import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/models/index.dart';
import 'package:mobile/screens/home/widgets/index.dart';
import 'package:mobile/store/index.dart';
import 'package:mobile/store/local_storage.dart';
import 'package:mobile/utils.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Future<String?> modal = showModalBottomSheet(
            context: context,
            builder: (_) => NewGoalModal(),
          );
          modal.then((s) {
            if (s != null && s.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('New goal created!'),
                duration: Duration(seconds: 2),
              ));
              Store<AppState> store = StoreProvider.of<AppState>(context);
              final newGoal = Goal(
                  goalID: const Uuid().v4(),
                  title: s,
                  year: store.state.date.year,
                  createdOn: DateTime.now());
              store.dispatch(CreateGoalAction(goal: newGoal));
              LocalStorage.saveGoals(store.state.goals);
            }
          });
        },
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text('hi, Nico'),
        backgroundColor: Colors.white,
        elevation: 1,
      );

  Widget _buildBody() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  Widget _buildStatsAndSelector() {
    return Row(
      children: [
        _buildPieCard(),
        _buildYearSelectorCard(),
      ],
    );
  }

  Widget _buildPieCard() => SizedBox(
        width: 120,
        height: 120,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
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
                      .where((g) => g.year == state.date.year)
                      .toList()),
            ),
          ],
        ),
        converter: (store) => store.state,
      );
}
