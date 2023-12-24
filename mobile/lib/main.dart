import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/screens/goal/goal_view_screen.dart';
import 'package:mobile/screens/index.dart';
import 'package:mobile/store/index.dart';
import 'package:mobile/store/local_storage.dart';
import 'package:redux/redux.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState initialState =
      AppState(date: DateTime.now(), goals: await LocalStorage.getSavedGoals());
  runApp(MyApp(
    initialState: initialState,
  ));
}

class MyApp extends StatelessWidget {
  final AppState initialState;
  late final Store<AppState> _store = Store<AppState>(
    reduce,
    initialState: initialState,
  );

  MyApp({
    super.key,
    required this.initialState,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: _store,
      child: MaterialApp(
        title: 'YGoal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
