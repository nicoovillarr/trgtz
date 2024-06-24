import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/api/index.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/auth/index.dart';
import 'package:trgtz/screens/goal/index.dart';
import 'package:trgtz/screens/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState initialState = AppState(
    date: DateTime.now(),
  );

  bool loggedIn = false;
  if (await Security.internalLogIn()) {
    Map<String, dynamic> user = await getUser();
    initialState = initialState.copyWith(
      user: user['user'],
      goals: user['goals'],
    );
    loggedIn = true;
  }

  FlutterNativeSplash.remove();

  runApp(MyApp(
    initialState: initialState,
    initialRoute: loggedIn ? '/home' : '/login',
  ));
}

Future<Map<String, dynamic>> getUser() async {
  Map<String, dynamic> result = {};
  final meResponse = await UserApiService().getMe();
  result['user'] = User.fromJson(meResponse.content);
  result['goals'] = (meResponse.content['goals'] as List)
      .map((e) => Goal.fromJson(e))
      .toList();
  return result;
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
        },
      ),
    );
  }
}
