// ignore_for_file: public_member_api_docs, sort_constructors_first
class DatabseExceptions implements Exception {
  String? message;
  Exception? exception;

  DatabseExceptions({
    this.message,
    this.exception,
  });

  @override
  String toString() =>
      'DatabseExceptions(message: $message, exception: $exception)';
}
