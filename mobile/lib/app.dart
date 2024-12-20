// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/base_screen.dart';
import 'package:trgtz/screens/admin/index.dart';
import 'package:trgtz/screens/admin/providers/index.dart';
import 'package:trgtz/screens/goal/providers/index.dart';
import 'package:trgtz/screens/profile/index.dart';
import 'package:trgtz/screens/profile/providers/index.dart';
import 'package:trgtz/screens/report/index.dart';
import 'package:trgtz/screens/report/providers/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/screens/friends/providers/index.dart';

import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/home/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/friends/index.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final String flavor;
  final ApplicationState initialState;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialState,
    required this.initialRoute,
    this.flavor = 'development',
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoading = false;
  StreamSubscription? _subscription;

  late final Store<ApplicationState> _store = Store<ApplicationState>(
    reduce,
    initialState: widget.initialState,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loaderSubscribe();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loaderDispose();
    super.dispose();
  }

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
            ),
          ),
          builder: (context, child) => Stack(
            children: [
              if (child != null) child,
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          initialRoute: widget.initialRoute,
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
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
            '/profile/app-info': (context) => ChangeNotifierProvider(
                  // create: (_) => ProfileAppInfoProvider()
                  create: (context) => ProfileAppInfoProvider(context: context),
                  child: const ProfileAppInfoScreen(),
                ),
            '/profile/notifications': (context) => ChangeNotifierProvider(
                create: (_) => ProfileNotificationsProvider(),
                child: const ProfileNotificationsScreen()),
            '/reports': (context) => ChangeNotifierProvider(
                  create: (context) => ReportsListProvider(),
                  child: const ReportsListView(),
                ),
            '/reports/single': (context) => ChangeNotifierProvider(
                  create: (context) => SingleReportProvider(),
                  child: const SingleReportView(),
                ),
            '/admin': (context) => ChangeNotifierProvider(
                  create: (context) => PendingReportsProvider(),
                  child: const PendingReportsScreen(),
                ),
          },
        ),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      WebSocketService.getInstance().close();
      _loaderDispose();
    } else if (state == AppLifecycleState.resumed &&
        navigatorKey.currentContext != null) {
      _loaderSubscribe();
      final store =
          StoreProvider.of<ApplicationState>(navigatorKey.currentContext!);
      if (store.state.user != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          UserService().getProfile(store.state.user!.id).then((user) {
            store.dispatch(SetUserAction(user: user['user']));
            store.dispatch(SetGoalsAction(goals: user['goals']));
            store.dispatch(SetFriendsAction(friends: user['friends']));
            store.dispatch(SetAlertsAction(alerts: user['alerts']));
            WebSocketService.getInstance().init();
          }).catchError((_) {});
        });
      }
    }
  }

  void _loaderSubscribe() {
    if (_subscription != null) {
      return;
    }

    _subscription = _store.onChange
        .map((event) => event.isLoading ?? false)
        .listen((isLoading) {
      if (isLoading != _isLoading) {
        setState(() => _isLoading = isLoading);
      }
    });
  }

  void _loaderDispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
