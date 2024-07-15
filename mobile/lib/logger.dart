import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:trgtz/store/local_storage.dart';

class Logger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logCustomEvent(
      String eventName, Map<String, Object> parameters) async {
    final Map<String, Object> parameters = {};
    final user = await LocalStorage.getUserID();
    if (user != null) {
      parameters['user_id'] = user;
    }
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  static Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  static Future<void> logSignup() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }
}
