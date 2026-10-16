import '../core/constants/app_constants.dart';

class DelegationNode {
  final int taskId;
  final String id;
  final String ticketId;
  final int ticketIdInt;
  final int? parentTaskId;
  final String ticketOwnerName;
  final int assignedFromUserId;
  final String assignedFromUserName;
  final int assignedToUserId;
  final String assignedToUserName;
  final String teamName;
  final int delegationLevel; // 1 for A->B, 2 for B->C, 3 for C->D
  final String reason;
  final String instructions;
  final DateTime delegatedAt;
  final DateTime? dueAt;
  final DateTime? startedAt;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, RETURNED, CANCELLED
  final String? completionNotes;
  final String? returnReason;
  final DateTime? completedAt;
  final String? completedByUserName;
  final List<DelegationNode> childTasks;

  // Compatibility getters
  String get fromUserName => assignedFromUserName;
  String get toUserName => assignedToUserName;
  String? get parentDelegationId => parentTaskId?.toString();

  DelegationNode({
    int? taskId,
    String? id,
    required this.ticketId,
    int? ticketIdInt,
    this.parentTaskId,
    String? parentDelegationId,
    this.ticketOwnerName = '',
    this.assignedFromUserId = 0,
    String? assignedFromUserName,
    String? fromUserName,
    this.assignedToUserId = 0,
    String? assignedToUserName,
    String? toUserName,
    this.teamName = 'Support Team',
    required this.delegationLevel,
    required this.reason,
    required this.instructions,
    required this.delegatedAt,
    this.dueAt,
    this.startedAt,
    required this.status,
    this.completionNotes,
    this.returnReason,
    this.completedAt,
    this.completedByUserName,
    this.childTasks = const [],
  })  : taskId = taskId ?? (int.tryParse(id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0),
        id = id ?? (taskId?.toString() ?? '0'),
        ticketIdInt = ticketIdInt ?? (int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
        assignedFromUserName = assignedFromUserName ?? fromUserName ?? 'Agent',
        assignedToUserName = assignedToUserName ?? toUserName ?? 'Agent';

  DelegationNode copyWith({
    int? taskId,
    String? id,
    String? ticketId,
    int? ticketIdInt,
    int? parentTaskId,
    String? parentDelegationId,
    String? ticketOwnerName,
    int? assignedFromUserId,
    String? assignedFromUserName,
    String? fromUserName,
    int? assignedToUserId,
    String? assignedToUserName,
    String? toUserName,
    String? teamName,
    int? delegationLevel,
    String? reason,
    String? instructions,
    DateTime? delegatedAt,
    DateTime? dueAt,
    DateTime? startedAt,
    String? status,
    String? completionNotes,
    String? returnReason,
    DateTime? completedAt,
    String? completedByUserName,
    List<DelegationNode>? childTasks,
  }) {
    return DelegationNode(
      taskId: taskId ?? this.taskId,
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      ticketIdInt: ticketIdInt ?? this.ticketIdInt,
      parentTaskId: parentTaskId ?? (parentDelegationId != null ? int.tryParse(parentDelegationId) : this.parentTaskId),
      ticketOwnerName: ticketOwnerName ?? this.ticketOwnerName,
      assignedFromUserId: assignedFromUserId ?? this.assignedFromUserId,
      assignedFromUserName: assignedFromUserName ?? fromUserName ?? this.assignedFromUserName,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? toUserName ?? this.assignedToUserName,
      teamName: teamName ?? this.teamName,
      delegationLevel: delegationLevel ?? this.delegationLevel,
      reason: reason ?? this.reason,
      instructions: instructions ?? this.instructions,
      delegatedAt: delegatedAt ?? this.delegatedAt,
      dueAt: dueAt ?? this.dueAt,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      completionNotes: completionNotes ?? this.completionNotes,
      returnReason: returnReason ?? this.returnReason,
      completedAt: completedAt ?? this.completedAt,
      completedByUserName: completedByUserName ?? this.completedByUserName,
      childTasks: childTasks ?? this.childTasks,
    );
  }

  factory DelegationNode.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['taskId'];
    final parsedTaskId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    final rawTicketId = json['ticketId'] ?? '0';
    final parsedTicketIdInt = rawTicketId is int
        ? rawTicketId
        : int.tryParse(rawTicketId.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final fromName = json['assignedFromUserName']?.toString() ??
        json['fromUserName']?.toString() ??
        'Agent';
    final toName = json['assignedToUserName']?.toString() ??
        json['toUserName']?.toString() ??
        'Agent';

    final fromId = json['assignedFromUserId'] is int
        ? json['assignedFromUserId']
        : int.tryParse(json['assignedFromUserId']?.toString() ?? '0') ?? 0;
    final toId = json['assignedToUserId'] is int
        ? json['assignedToUserId']
        : int.tryParse(json['assignedToUserId']?.toString() ?? '0') ?? 0;

    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    DateTime? parseNullable(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    List<DelegationNode> children = [];
    if (json['childTasks'] is List) {
      children = (json['childTasks'] as List)
          .map((e) => DelegationNode.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final level = json['delegationLevel'] is int
        ? json['delegationLevel']
        : int.tryParse(json['delegationLevel']?.toString() ?? '1') ?? 1;

    final parentRaw = json['parentTaskId'] ?? json['parentDelegationId'];

    return DelegationNode(
      taskId: parsedTaskId,
      id: parsedTaskId.toString(),
      ticketId: parsedTicketIdInt.toString(),
      ticketIdInt: parsedTicketIdInt,
      parentTaskId: parentRaw is int ? parentRaw : int.tryParse(parentRaw?.toString() ?? ''),
      ticketOwnerName: json['ticketOwnerName']?.toString() ?? '',
      assignedFromUserId: fromId,
      assignedFromUserName: fromName,
      assignedToUserId: toId,
      assignedToUserName: toName,
      teamName: json['teamName']?.toString() ?? json['targetTeamName']?.toString() ?? AppConstants.teamSupport,
      delegationLevel: level,
      reason: json['reason']?.toString() ?? AppConstants.reasonWorkload,
      instructions: json['instructions']?.toString() ?? '',
      delegatedAt: parseDate(json['createdAt'] ?? json['delegatedAt'], DateTime.now()),
      dueAt: parseNullable(json['dueAt']),
      startedAt: parseNullable(json['startedAt']),
      status: json['status']?.toString() ?? AppConstants.taskPending,
      completionNotes: json['completionNotes']?.toString(),
      returnReason: json['returnReason']?.toString(),
      completedAt: parseNullable(json['completedAt']),
      completedByUserName: json['completedByUserName']?.toString(),
      childTasks: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': taskId,
      'taskId': taskId,
      'ticketId': ticketIdInt,
      'parentTaskId': parentTaskId,
      'ticketOwnerName': ticketOwnerName,
      'assignedFromUserId': assignedFromUserId,
      'assignedFromUserName': assignedFromUserName,
      'fromUserName': assignedFromUserName,
      'assignedToUserId': assignedToUserId,
      'assignedToUserName': assignedToUserName,
      'toUserName': assignedToUserName,
      'teamName': teamName,
      'delegationLevel': delegationLevel,
      'reason': reason,
      'instructions': instructions,
      'createdAt': delegatedAt.toIso8601String(),
      'delegatedAt': delegatedAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'status': status,
      'completionNotes': completionNotes,
      'returnReason': returnReason,
      'completedAt': completedAt?.toIso8601String(),
      'completedByUserName': completedByUserName,
      'childTasks': childTasks.map((e) => e.toJson()).toList(),
    };
  }
}
