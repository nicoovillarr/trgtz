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
        child: Wrap(
          direction: Axis.vertical,
          children: _buildRows(),
        ),
      );

  List<Widget> _buildRows() => [
        _buildProgressBar(),
      ];

  Widget _buildProgressBar() => StoreConnector<AppState, DateTime>(
        builder: (ctx, date) => Column(children: [
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
        ]),
        converter: (store) => store.state.date,
      );
}
