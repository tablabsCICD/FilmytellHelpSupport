import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class DashboardSummaryData {
  final int totalTickets;
  final int openTickets;
  final int urgentTickets;
  final int highPriorityTickets;
  final int pendingUserTickets;
  final int inProgressTickets;
  final int resolvedTickets;
  final int closedTickets;
  final int slaBreachedTickets;
  final int aiResolvedTickets;
  final int aiEscalatedTickets;
  final double averageResolutionTimeMinutes;
  final double averageFirstResponseTimeMinutes;
  final int totalDelegatedTasks;
  final double averageDelegationDepth;
  final Map<String, int> ticketsByStatus;
  final Map<String, int> ticketsByPriority;
  final Map<String, int> ticketsBySourcePortal;

  DashboardSummaryData({
    required this.totalTickets,
    required this.openTickets,
    required this.urgentTickets,
    required this.highPriorityTickets,
    required this.pendingUserTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
    required this.closedTickets,
    required this.slaBreachedTickets,
    required this.aiResolvedTickets,
    required this.aiEscalatedTickets,
    required this.averageResolutionTimeMinutes,
    required this.averageFirstResponseTimeMinutes,
    required this.totalDelegatedTasks,
    required this.averageDelegationDepth,
    required this.ticketsByStatus,
    required this.ticketsByPriority,
    required this.ticketsBySourcePortal,
  });

  factory DashboardSummaryData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '0.0') ?? 0.0;
    }

    Map<String, int> parseMap(dynamic map) {
      if (map is Map) {
        return map.map((k, v) => MapEntry(k.toString(), parseInt(v)));
      }
      return {};
    }

    return DashboardSummaryData(
      totalTickets: parseInt(json['totalTickets']),
      openTickets: parseInt(json['openTickets']),
      urgentTickets: parseInt(json['urgentTickets']),
      highPriorityTickets: parseInt(json['highPriorityTickets']),
      pendingUserTickets: parseInt(json['pendingUserTickets']),
      inProgressTickets: parseInt(json['inProgressTickets']),
      resolvedTickets: parseInt(json['resolvedTickets']),
      closedTickets: parseInt(json['closedTickets']),
      slaBreachedTickets: parseInt(json['slaBreachedTickets']),
      aiResolvedTickets: parseInt(json['aiResolvedTickets']),
      aiEscalatedTickets: parseInt(json['aiEscalatedTickets']),
      averageResolutionTimeMinutes: parseDouble(json['averageResolutionTimeMinutes']),
      averageFirstResponseTimeMinutes: parseDouble(json['averageFirstResponseTimeMinutes']),
      totalDelegatedTasks: parseInt(json['totalDelegatedTasks']),
      averageDelegationDepth: parseDouble(json['averageDelegationDepth']),
      ticketsByStatus: parseMap(json['ticketsByStatus']),
      ticketsByPriority: parseMap(json['ticketsByPriority']),
      ticketsBySourcePortal: parseMap(json['ticketsBySourcePortal']),
    );
  }
}

class DashboardApiService {
  final ApiClient _apiClient;

  DashboardApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get aggregated backend dashboard summary metrics
  Future<DashboardSummaryData?> getDashboardSummary() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.dashboardSummary);
      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'] ?? responseJson;
        return DashboardSummaryData.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  /// Get team and agent workloads
  Future<List<Map<String, dynamic>>> getTeamWorkload() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.dashboardTeamWorkload);
      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
