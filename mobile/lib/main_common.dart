import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/app.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/screens/profile/providers/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void showErrorDialog(GlobalKey<NavigatorState> navigator, Object error) {
  BuildContext context = navigator.currentContext!;
  Store<AppState> store = StoreProvider.of<AppState>(context);
  store.dispatch(const SetIsLoadingAction(isLoading: false));
  WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
      context: navigator.currentContext!,
      builder: (context) =>
          ErrorDialog(innerException: error is AppException ? error : null)));
}

void mainCommon({
  required String flavor,
  required FirebaseOptions options,
}) async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env.$flavor');
  await Firebase.initializeApp(options: options);
  await FirebaseHelperService.init();
  AppState initialState = AppState(
    date: DateTime.now(),
  );

  bool loggedIn = false;
  String? userId = await Security.internalLogIn();
  if (userId != null && userId.isNotEmpty) {
    Map<String, dynamic> user = await UserService().getProfile(userId);
    initialState = initialState.copyWith(
      user: user['user'],
      goals: user['goals'],
      friends: user['friends'],
      alerts: user['alerts'],
    );
    loggedIn = true;

    final ws = WebSocketService.getInstance();
    await ws.init();
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    showErrorDialog(navigatorKey, errorDetails.exception);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    showErrorDialog(navigatorKey, error);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SingleProfileProvider()),
      ],
      child: MyApp(
        flavor: 'flavor',
        initialState: initialState,
        initialRoute: loggedIn ? '/home' : '/login',
      ),
    ),
  );
}
