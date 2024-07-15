import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/firebase_options.dart';
import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/friends/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';

final navigator = GlobalKey<NavigatorState>();

void showErrorDialog(GlobalKey<NavigatorState> navigator, Object error) {
  BuildContext context = navigator.currentContext!;
  Store<AppState> store = StoreProvider.of<AppState>(context);
  store.dispatch(const SetIsLoadingAction(isLoading: false));
  WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
      context: navigator.currentContext!,
      builder: (context) =>
          ErrorDialog(innerException: error is AppException ? error : null)));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState initialState = AppState(
    date: DateTime.now(),
  );

  bool loggedIn = false;
  if (await Security.internalLogIn()) {
    Map<String, dynamic> user = await UserService().getMe();
    initialState = initialState.copyWith(
      user: user['user'],
      goals: user['goals'],
      friends: user['friends'],
      alerts: user['alerts'],
    );
    loggedIn = true;
  }

  FlutterNativeSplash.remove();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    showErrorDialog(navigator, errorDetails.exception);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    showErrorDialog(navigator, error);
    return true;
  };

  runApp(MyApp(
    navigatorKey: navigator,
    initialState: initialState,
    initialRoute: loggedIn ? '/home' : '/login',
  ));
}

class MyApp extends StatelessWidget {
  final AppState initialState;
  final String initialRoute;
  final GlobalKey<NavigatorState> navigatorKey;
  late final Store<AppState> _store = Store<AppState>(
    reduce,
    initialState: initialState,
  );

  MyApp({
    super.key,
    required this.initialState,
    required this.initialRoute,
    required this.navigatorKey,
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
