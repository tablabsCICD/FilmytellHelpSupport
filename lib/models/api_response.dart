class ApiResponse<T> {
  final bool success;
  final String message;
  final String? errorCode;
  final T? data;
  final List<String> errors;
  final int statusCode;
  final String? timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.errorCode,
    this.data,
    this.errors = const [],
    this.statusCode = 200,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? createT, {
    int statusCode = 200,
  }) {
    List<String> parsedErrors = [];
    if (json['errors'] is List) {
      parsedErrors = (json['errors'] as List).map((e) => e.toString()).toList();
    } else if (json['data'] is Map && json['success'] == false) {
      // Map of field validation errors
      final map = json['data'] as Map;
      parsedErrors = map.entries.map((e) => '${e.key}: ${e.value}').toList();
    }

    final isSuccess = json['success'] is bool
        ? json['success'] as bool
        : (statusCode >= 200 && statusCode < 300);

    return ApiResponse<T>(
      success: isSuccess,
      message: json['message']?.toString() ?? (isSuccess ? 'Success' : 'Request failed'),
      errorCode: json['errorCode']?.toString(),
      data: json['data'] != null && createT != null ? createT(json['data']) : null,
      errors: parsedErrors,
      statusCode: statusCode,
      timestamp: json['timestamp']?.toString(),
    );
  }
}

class PageResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool success;

  PageResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    this.success = true,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) createItem,
  ) {
    // Backend PageResponse has `data: List<T>` or Spring Data Page has `content: List<T>`
    final rawList = json['data'] ?? json['content'] ?? [];
    final List<T> items = rawList is List
        ? rawList.map((e) => createItem(e)).toList()
        : [];

    final rawPage = json['page'] ?? json['pageNumber'] ?? 0;
    final rawSize = json['size'] ?? json['pageSize'] ?? 20;
    final rawTotal = json['totalElements'] ?? 0;
    final rawTotalPages = json['totalPages'] ?? 1;
    final rawLast = json['last'] ?? true;

    return PageResponse<T>(
      content: items,
      pageNumber: rawPage is int ? rawPage : int.tryParse(rawPage.toString()) ?? 0,
      pageSize: rawSize is int ? rawSize : int.tryParse(rawSize.toString()) ?? 20,
      totalElements: rawTotal is int ? rawTotal : int.tryParse(rawTotal.toString()) ?? items.length,
      totalPages: rawTotalPages is int ? rawTotalPages : int.tryParse(rawTotalPages.toString()) ?? 1,
      last: rawLast is bool ? rawLast : rawLast.toString().toLowerCase() == 'true',
      success: json['success'] is bool ? json['success'] : true,
    );
  }
}
