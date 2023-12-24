class ModelBase {
  static DateTime? tryParseDateTime(String key, Map<String, dynamic> json) {
    if (!json.containsKey(key) || json[key] == null || json[key] == "null") {
      return null;
    }

    return DateTime.parse(json[key]);
  }
}
