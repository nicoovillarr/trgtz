class ApiException extends Error {
  final String message;

  ApiException([this.message = '']);

  @override
  String toString() {
    return message;
  }
}
