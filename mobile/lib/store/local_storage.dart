// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:trgtz/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trgtz/security.dart';

class LocalStorage {
  static const String _GOALS_LIST_KEY = 'GOALS_LIST';
  static const String _TOKEN_KEY = 'TOKEN_LIST';
  static const String _EMAIL_KEY = 'EMAIL_KEY';
  static const String _PASS_KEY = 'PASS_KEY';

  static Future<List<Goal>> getSavedGoals() async {
    final instance = await SharedPreferences.getInstance();
    final List<String> json = instance.getStringList(_GOALS_LIST_KEY) ?? [];
    return json.map((e) => Goal.fromJson(jsonDecode(e))).toList();
  }

  static Future saveGoals(List<Goal> goals) async {
    final instance = await SharedPreferences.getInstance();
    instance.setStringList(
        _GOALS_LIST_KEY, goals.map((g) => jsonEncode(g.toJson())).toList());
  }

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
}
