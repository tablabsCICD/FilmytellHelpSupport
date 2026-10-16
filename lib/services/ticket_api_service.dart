import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/rating_review_model.dart';
import '../models/support_ticket_model.dart';

class TicketApiService {
  final ApiClient _apiClient;

  TicketApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Search and filter tickets with server-side pagination
  Future<PageResponse<SupportTicket>> searchTickets({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? priority,
    String? sourcePortal,
    int? teamId,
    int? ownerId,
    int? assigneeId,
    bool? slaBreached,
    bool? aiResolved,
    String sortBy = 'createdAt',
    String direction = 'DESC',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'direction': direction,
    };

    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty && priority != 'All') queryParams['priority'] = priority;
    if (sourcePortal != null && sourcePortal.isNotEmpty && sourcePortal != 'All') queryParams['sourcePortal'] = sourcePortal;
    if (teamId != null) queryParams['teamId'] = teamId;
    if (ownerId != null) queryParams['ownerId'] = ownerId;
    if (assigneeId != null) queryParams['assigneeId'] = assigneeId;
    if (slaBreached != null) queryParams['slaBreached'] = slaBreached;
    if (aiResolved != null) queryParams['aiResolved'] = aiResolved;

    final responseJson = await _apiClient.get(
      ApiEndpoints.tickets,
      queryParameters: queryParams,
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      return PageResponse<SupportTicket>.fromJson(
        responseJson,
        (json) => SupportTicket.fromJson(json as Map<String, dynamic>),
      );
    }

    return PageResponse<SupportTicket>(
      content: [],
      pageNumber: page,
      pageSize: size,
      totalElements: 0,
      totalPages: 1,
      last: true,
    );
  }

  /// Get comprehensive ticket details
  Future<SupportTicket> getTicketDetails(dynamic id) async {
    final responseJson = await _apiClient.get(ApiEndpoints.ticketDetails(id));
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Invalid ticket details response format');
  }

  /// Create internal ticket
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String priority,
    required String category,
    String? subCategory,
    String sourcePortal = 'FILMYTELL',
    String? customerName,
    String? customerEmail,
    int? teamId,
    int? assigneeId,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'description': description,
      'priority': priority,
      'category': category,
      'sourcePortal': sourcePortal,
    };
    if (subCategory != null) body['subCategory'] = subCategory;
    if (customerName != null) body['customerName'] = customerName;
    if (customerEmail != null) body['customerEmail'] = customerEmail;
    if (teamId != null) body['teamId'] = teamId;
    if (assigneeId != null) body['assigneeId'] = assigneeId;

    final responseJson = await _apiClient.post(ApiEndpoints.tickets, body: body);
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to create ticket');
  }

  /// Assign ticket to agent & team
  Future<SupportTicket> assignTicket(
    dynamic id, {
    required int assigneeId,
    required int teamId,
    String? reason,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketAssign(id),
      body: {
        'assigneeId': assigneeId,
        'teamId': teamId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to assign ticket');
  }

  /// Transfer ownership to another agent
  Future<SupportTicket> transferOwnership(
    dynamic id, {
    required int newOwnerId,
    required String reason,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketTransferOwnership(id),
      body: {
        'newOwnerId': newOwnerId,
        'reason': reason,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to transfer ticket ownership');
  }

  /// Update ticket status with backend validation
  Future<SupportTicket> updateStatus(
    dynamic id, {
    required String status,
    String? reason,
  }) async {
    final responseJson = await _apiClient.patch(
      ApiEndpoints.ticketStatus(id),
      body: {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to update ticket status');
  }

  /// Update ticket priority with audit reason
  Future<SupportTicket> updatePriority(
    dynamic id, {
    required String priority,
    required String reason,
  }) async {
    final responseJson = await _apiClient.patch(
      ApiEndpoints.ticketPriority(id),
      body: {
        'priority': priority,
        'reason': reason,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to update ticket priority');
  }

  /// Mark ticket as resolved
  Future<SupportTicket> resolveTicket(dynamic id, {String? notes}) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketResolve(id),
      queryParameters: notes != null && notes.isNotEmpty ? {'notes': notes} : null,
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to resolve ticket');
  }

  /// Close ticket permanently
  Future<SupportTicket> closeTicket(dynamic id) async {
    final responseJson = await _apiClient.post(ApiEndpoints.ticketClose(id));
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to close ticket');
  }

  /// Reopen ticket
  Future<SupportTicket> reopenTicket(dynamic id, {String reason = 'Reopened for further review'}) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketReopen(id),
      queryParameters: {'reason': reason},
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return SupportTicket.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to reopen ticket');
  }

  /// Trigger synchronization with Admin Portal tickets
  Future<Map<String, dynamic>> syncTickets() async {
    final responseJson = await _apiClient.post(ApiEndpoints.ticketSync);
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    }
    throw Exception('Failed to sync tickets');
  }

  /// Legacy helper for backwards compatibility
  Future<ApiResponse<RatingReviewPagination>> getRatingAndReviews({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final responseJson = await _apiClient.get(
        ApiEndpoints.ratingAndReviewGetAll,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      if (responseJson != null && responseJson is Map<String, dynamic>) {
        return ApiResponse<RatingReviewPagination>.fromJson(
          responseJson,
          (data) {
            final wrapper = RatingReviewDataWrapper.fromJson(data as Map<String, dynamic>);
            return wrapper.ratingAndReview ??
                RatingReviewPagination(
                  content: [],
                  last: true,
                  totalElements: 0,
                  totalPages: 1,
                  first: true,
                  size: size,
                  number: page,
                  numberOfElements: 0,
                  empty: true,
                );
          },
        );
      }
    } catch (_) {}

    return ApiResponse<RatingReviewPagination>(
      message: 'Cached fallback',
      statusCode: 200,
      success: true,
      data: RatingReviewPagination(
        content: [],
        last: true,
        totalElements: 0,
        totalPages: 1,
        first: true,
        size: size,
        number: page,
        numberOfElements: 0,
        empty: true,
      ),
    );
  }
}
