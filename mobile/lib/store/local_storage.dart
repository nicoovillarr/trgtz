// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:mobile/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _GOALS_LIST_KEY = 'GOALS_LIST';

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
}
