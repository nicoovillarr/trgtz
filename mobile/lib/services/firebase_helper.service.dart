import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trgtz/services/index.dart';

class FirebaseHelperService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _androidChannel = AndroidNotificationChannel(
    'trgtz',
    'Trgtz Notifications',
    importance: Importance.max,
  );

  static Future<String?> get token async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('Unsupported platform');
    }
    
    try {
      if (Platform.isAndroid) {
        return _firebaseMessaging.getToken();
      } else if (Platform.isIOS) {
        return _firebaseMessaging.getAPNSToken();
      }
    } catch (e) {
      FirebaseCrashlytics.instance.log('Failed to get token: $e');
    }

    return null;
  }

  static Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    await initPushNotifications();
    await initLocalNotifications();
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      await SessionService().updateFirebaseToken(token);
    });
  }

  static Future initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            icon: '@drawable/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  static Future initLocalNotifications() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      onDidReceiveNotificationResponse: onNotificationTap,
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  static void onNotificationTap(NotificationResponse details) {
    final message = jsonDecode(details.payload!);
    handleMessage(RemoteMessage.fromMap(message));
  }

  static void handleMessage(RemoteMessage? message) {
    if (message == null) return;
  }

  static Future _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    handleMessage(message);
  }
}
