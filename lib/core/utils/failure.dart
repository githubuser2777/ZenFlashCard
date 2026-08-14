class Failure {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  Failure(this.message, {this.error, this.stackTrace});

  @override
  String toString() => 'Failure(message: $message, error: $error)';
}
