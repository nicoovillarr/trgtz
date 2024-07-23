import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/store/index.dart';

import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/home/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/friends/index.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String flavor;
  final AppState initialState;
  final String initialRoute;
  late final Store<AppState> _store = Store<AppState>(
    reduce,
    initialState: initialState,
  );

  MyApp({
    super.key,
    required this.initialState,
    required this.initialRoute,
    this.flavor = 'development',
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: _store,
      child: MaterialApp(
        title: appName,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0),
            ),
          ),
        ),
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/goal': (context) => const GoalViewScreen(),
          '/goal/milestones': (context) => const GoalMilestonesView(),
          '/friends': (context) => const FriendsListScreen(),
        },
      ),
    );
  }
}
