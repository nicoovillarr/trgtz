// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/base_screen.dart';
import 'package:trgtz/screens/goal/providers/index.dart';
import 'package:trgtz/screens/profile/index.dart';
import 'package:trgtz/screens/report/index.dart';
import 'package:trgtz/screens/report/providers/index.dart';
import 'package:trgtz/screens/report/single_report_view.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/screens/friends/providers/index.dart';

import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/home/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/friends/index.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String flavor;
  final ApplicationState initialState;
  final String initialRoute;
  late final Store<ApplicationState> _store = Store<ApplicationState>(
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
  Widget build(BuildContext context) => StoreProvider(
        store: _store,
        child: MaterialApp(
          title: appName,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
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
          // initialRoute: '/forgot-password',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const PasswordResetScreen(),
            '/home': (context) => const HomeScreen(),
            '/goal': (context) => ChangeNotifierProvider(
                  create: (context) => SingleGoalProvider(),
                  child: const SingleGoalScreen(),
                ),
            '/goal/milestones': (context) => ChangeNotifierProvider(
                  create: (_) => SingleGoalProvider(),
                  child: const GoalMilestonesView(),
                ),
            '/friends': (context) => ChangeNotifierProvider(
                  create: (context) => FriendsListScreenProvider(),
                  child: const FriendsListScreen(),
                ),
            '/profile/app-info': (context) => const ProfileAppInfoScreen(),
            '/reports': (context) => ChangeNotifierProvider(
                  create: (context) => ReportsListProvider(),
                  child: const ReportsListView(),
                ),
            '/reports/single': (context) => ChangeNotifierProvider(
                  create: (context) => SingleReportProvider(),
                  child: const SingleReportView(),
                ),
          },
        ),
      );
}
