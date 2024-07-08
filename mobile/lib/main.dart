import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/index.dart';
import 'package:trgtz/screens/profile/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';

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
    );
    loggedIn = true;
  }

  FlutterNativeSplash.remove();

  runApp(MyApp(
    initialState: initialState,
    initialRoute: loggedIn ? '/home' : '/login',
  ));
}

class MyApp extends StatelessWidget {
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
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: _store,
      child: MaterialApp(
        title: appName,
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
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
