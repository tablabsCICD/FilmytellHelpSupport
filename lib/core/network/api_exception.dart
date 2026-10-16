class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final List<String> errors;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.errors = const [],
    this.details,
  });

  @override
  String toString() {
    if (errors.isNotEmpty) {
      return '$message: ${errors.join(', ')}';
    }
    return message;
  }
}
