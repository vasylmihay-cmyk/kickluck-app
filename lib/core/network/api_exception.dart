class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiRateLimitException extends ApiException {
  const ApiRateLimitException()
      : super('API request limit reached. Please try again later.', statusCode: 429);
}
