import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/support_ticket_model.dart';

class KanbanColumnData {
  final String status;
  final String title;
  final int count;
  final List<SupportTicket> tickets;

  KanbanColumnData({
    required this.status,
    required this.title,
    required this.count,
    required this.tickets,
  });

  factory KanbanColumnData.fromJson(Map<String, dynamic> json) {
    final rawTickets = json['tickets'];
    final List<SupportTicket> parsedTickets = rawTickets is List
        ? rawTickets.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return KanbanColumnData(
      status: json['status']?.toString() ?? 'NEW',
      title: json['title']?.toString() ?? json['status']?.toString() ?? 'Column',
      count: json['count'] is int ? json['count'] : parsedTickets.length,
      tickets: parsedTickets,
    );
  }
}

class KanbanBoardData {
  final List<KanbanColumnData> columns;
  final int totalTickets;

  KanbanBoardData({
    required this.columns,
    required this.totalTickets,
  });

  factory KanbanBoardData.fromJson(Map<String, dynamic> json) {
    final rawCols = json['columns'];
    final List<KanbanColumnData> parsedCols = rawCols is List
        ? rawCols.map((e) => KanbanColumnData.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    final total = json['totalTickets'] is int
        ? json['totalTickets']
        : int.tryParse(json['totalTickets']?.toString() ?? '0') ?? 0;

    return KanbanBoardData(
      columns: parsedCols,
      totalTickets: total,
    );
  }
}

class KanbanApiService {
  final ApiClient _apiClient;

  KanbanApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch full Kanban board with 8 status columns and ticket cards
  Future<KanbanBoardData> getKanbanBoard({
    int? teamId,
    int? assigneeId,
    String? priority,
    String? sourcePortal,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (teamId != null) queryParams['teamId'] = teamId;
    if (assigneeId != null) queryParams['assigneeId'] = assigneeId;
    if (priority != null && priority.isNotEmpty && priority != 'All') queryParams['priority'] = priority;
    if (sourcePortal != null && sourcePortal.isNotEmpty && sourcePortal != 'All') queryParams['sourcePortal'] = sourcePortal;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final responseJson = await _apiClient.get(
      ApiEndpoints.kanban,
      queryParameters: queryParams,
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return KanbanBoardData.fromJson(data as Map<String, dynamic>);
    }

    return KanbanBoardData(columns: [], totalTickets: 0);
  }
}
