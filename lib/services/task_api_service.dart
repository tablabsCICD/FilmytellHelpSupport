import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/delegation_model.dart';

class TaskApiService {
  final ApiClient _apiClient;

  TaskApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Delegate ticket task to another agent (maintains A -> B -> C hierarchy)
  Future<DelegationNode> delegateTask(
    dynamic ticketId, {
    required int assignToUserId,
    required String reason,
    required String instructions,
    DateTime? dueAt,
  }) async {
    final body = {
      'assignToUserId': assignToUserId,
      'reason': reason,
      'instructions': instructions,
      if (dueAt != null) 'dueAt': dueAt.toIso8601String(),
    };

    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketDelegate(ticketId),
      body: body,
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return DelegationNode.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to delegate task');
  }

  /// Get complete task delegation tree for ticket
  Future<List<DelegationNode>> getTasksForTicket(dynamic ticketId) async {
    final responseJson = await _apiClient.get(ApiEndpoints.ticketTasks(ticketId));
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'];
      if (data is List) {
        return data.map((e) => DelegationNode.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Start working on delegated task (moves status to IN_PROGRESS)
  Future<DelegationNode> startTask(dynamic taskId) async {
    final responseJson = await _apiClient.post(ApiEndpoints.taskStart(taskId));
    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return DelegationNode.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to start task');
  }

  /// Complete delegated subtask (cascades control back to parent delegator)
  Future<DelegationNode> completeTask(
    dynamic taskId, {
    required String completionNotes,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.taskComplete(taskId),
      body: {'completionNotes': completionNotes},
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return DelegationNode.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to complete task');
  }

  /// Return task back to delegator
  Future<DelegationNode> returnTask(
    dynamic taskId, {
    required String returnReason,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.taskReturn(taskId),
      body: {'returnReason': returnReason},
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return DelegationNode.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to return task');
  }

  /// Admin/Manager override task delegation
  Future<DelegationNode> overrideTask(
    dynamic taskId, {
    required int newAssigneeId,
    required String overrideReason,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.taskOverride(taskId),
      body: {
        'newAssigneeId': newAssigneeId,
        'overrideReason': overrideReason,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return DelegationNode.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to override task');
  }
}
