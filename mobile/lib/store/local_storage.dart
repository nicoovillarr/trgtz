// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trgtz/security.dart';

class LocalStorage {
  static const String _TOKEN_KEY = 'TOKEN_LIST';
  static const String _EMAIL_KEY = 'EMAIL_KEY';
  static const String _PASS_KEY = 'PASS_KEY';
  static const String _USER_ID_KEY = 'USER_ID_KEY';
  static const String _BROADCAST_TOKEN_KEY = 'BROADCAST_TOKEN_KEY';

  static Future<String?> getToken() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getString(_TOKEN_KEY);
  }

  static Future saveToken(String? token) async {
    final instance = await SharedPreferences.getInstance();
    if (token == null) {
      instance.remove(_TOKEN_KEY);
    } else {
      instance.setString(_TOKEN_KEY, token);
    }
  }

  static Future saveUserID(String? id) async {
    final instance = await SharedPreferences.getInstance();
    if (id == null) {
      instance.remove(_USER_ID_KEY);
    } else {
      instance.setString(_USER_ID_KEY, id);
    }
  }

  static Future<String?> getUserID() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getString(_USER_ID_KEY);
  }

  static Future<String?> getEmail() async {
    final instance = await SharedPreferences.getInstance();
    String? value = instance.getString(_EMAIL_KEY);
    return value != null ? Security.decrypt(value) : null;
  }

  static Future saveEmail(String? email) async {
    final instance = await SharedPreferences.getInstance();
    if (email == null) {
      instance.remove(_EMAIL_KEY);
    } else {
      instance.setString(_EMAIL_KEY, Security.encrypt(email));
    }
  }

  static Future<String?> getPass() async {
    final instance = await SharedPreferences.getInstance();
    String? value = instance.getString(_PASS_KEY);
    return value != null ? Security.decrypt(value) : null;
  }

  static Future savePass(String? pass) async {
    final instance = await SharedPreferences.getInstance();
    if (pass == null) {
      instance.remove(_PASS_KEY);
    } else {
      instance.setString(_PASS_KEY, Security.encrypt(pass));
    }
  }

  static Future getBroadcastToken() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getString(_BROADCAST_TOKEN_KEY);
  }

  static Future saveBroadcastToken(String? token) async {
    final instance = await SharedPreferences.getInstance();
    if (token == null) {
      instance.remove(_BROADCAST_TOKEN_KEY);
    } else {
      instance.setString(_BROADCAST_TOKEN_KEY, token);
    }
  }

  static Future clear() async {
    final instance = await SharedPreferences.getInstance();
    instance.remove(_TOKEN_KEY);
    instance.remove(_EMAIL_KEY);
    instance.remove(_PASS_KEY);
  }
}
