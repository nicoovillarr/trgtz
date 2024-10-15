class ModelBase {
  static DateTime? tryParseDateTime(String key, Map<String, dynamic> json) {
    if (!json.containsKey(key) || json[key] == null || json[key] == "null") {
      return null;
    }

    return DateTime.parse(json[key]);
  }

  static T enumFromString<T>(List<T> enumValues, String enumString) {
    return enumValues.firstWhere(
      (e) => e.toString().split('.').last == enumString,
      orElse: () => throw ArgumentError('Invalid enum value: $enumString'),
    );
  }
}
