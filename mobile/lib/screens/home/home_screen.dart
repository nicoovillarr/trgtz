import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/screens/home/widgets/progress_bar.dart';
import 'package:mobile/store/index.dart';
import 'package:mobile/utils.dart';

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
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text('hi, Nico'),
        backgroundColor: Colors.white,
        elevation: 1,
      );

  Widget _buildBody() => SingleChildScrollView(
        child: Column(
          children: _buildRows(),
        ),
      );

  List<Widget> _buildRows() => [
        _buildProgressBar(DateTime.now()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              _buildPieCard(),
              _buildYearSelectorCard(),
            ],
          ),
        ),
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

  Widget _buildPieCard() => const SizedBox(
        width: 120,
        height: 120,
        child: Card(),
      );

  Widget _buildYearSelectorCard() => Flexible(
        child: SizedBox(
          height: 120,
          child: Card(
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
}
