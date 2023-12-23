import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/store/index.dart';

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
        elevation: 5,
      );

  Widget _buildBody() => SingleChildScrollView(
        child: Wrap(
          direction: Axis.vertical,
          children: _buildRows(),
        ),
      );

  List<Widget> _buildRows() => [
        // ... content
        _buildReduxTest(),
      ];

  Widget _buildReduxTest() => StoreConnector<AppState, DateTime>(
        builder: (ctx, date) => Column(
          children: [
            Text(date.toString()),
            ElevatedButton(
              onPressed: () {
                StoreProvider.of<AppState>(ctx)
                    .dispatch(TestAction(newDate: DateTime.now()));
              },
              child: const Text('Update DateTime'),
            )
          ],
        ),
        converter: (store) => store.state.date,
      );
}
