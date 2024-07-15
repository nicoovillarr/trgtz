class AppException extends Error {
  final String message;

  AppException([this.message = '']);

  @override
  String toString() {
    return message;
  }
}
