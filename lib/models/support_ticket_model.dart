import 'delegation_model.dart';
import 'ticket_history_model.dart';
import 'ticket_message_model.dart';
import 'ai_analysis_model.dart';
import 'rating_review_model.dart';
import '../core/constants/app_constants.dart';

class SupportTicket {
  final int id;
  final String ticketId;
  final String ticketNumber;
  final int userId;
  final int contentId;
  final int rating;
  final String subject;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;
  final String priority;
  final String team;
  final int? assignedTeamId;
  final String ticketOwner;
  final int? ticketOwnerId;
  final String currentAssignee;
  final int? currentAssigneeId;
  final String? delegatedFrom;
  final int? delegatedFromId;
  final int delegationLevel;
  final String category;
  final String? subCategory;
  final String source;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? externalTicketId;
  final DateTime? slaResponseDueAt;
  final DateTime? slaResolutionDueAt;
  final bool slaBreached;
  final bool aiEligible;
  final double? aiConfidence;
  final bool aiResolved;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? resolutionNotes;
  final List<DelegationNode> delegations;
  final List<TicketHistory> history;
  final List<TicketMessage> messages;
  final List<TicketMessage> notes;
  final AiAnalysisResult? aiAnalysis;

  // Compatibility getter
  String get title => subject;

  SupportTicket({
    int? id,
    String? ticketId,
    required this.ticketNumber,
    this.userId = 0,
    this.contentId = 0,
    this.rating = 0,
    String? title,
    String? subject,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.priority,
    required this.team,
    this.assignedTeamId,
    required this.ticketOwner,
    this.ticketOwnerId,
    required this.currentAssignee,
    this.currentAssigneeId,
    this.delegatedFrom,
    this.delegatedFromId,
    this.delegationLevel = 0,
    required this.category,
    this.subCategory,
    required this.source,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.externalTicketId,
    this.slaResponseDueAt,
    this.slaResolutionDueAt,
    this.slaBreached = false,
    this.aiEligible = false,
    this.aiConfidence,
    this.aiResolved = false,
    this.resolvedAt,
    this.closedAt,
    this.resolutionNotes,
    this.delegations = const [],
    this.history = const [],
    this.messages = const [],
    this.notes = const [],
    this.aiAnalysis,
  })  : id = id ?? (int.tryParse(ticketId?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0),
        ticketId = ticketId ?? (id?.toString() ?? '0'),
        subject = subject ?? title ?? '';

  // Factory mapper to convert from Rating & Review API item
  factory SupportTicket.fromRatingReview(RatingReviewItem item, int index) {
    final numFormatted = (index + 1).toString().padLeft(4, '0');
    final ticketNum = 'FT-$numFormatted';
    final createdDate = item.createdAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(item.createdAt)
        : DateTime.now().subtract(Duration(hours: (index + 1) * 3));

    String initialPriority = AppConstants.priorityMedium;
    String initialCategory = 'Content Quality';
    String initialTeam = AppConstants.teamSupport;
    String initialStatus = AppConstants.statusNew;

    if (item.rating <= 2) {
      initialPriority = AppConstants.priorityHigh;
      initialCategory = 'User Dissatisfaction / Streaming Bug';
      initialTeam = AppConstants.teamTechnical;
    } else if (item.rating == 5) {
      initialPriority = AppConstants.priorityLow;
      initialCategory = 'User Feedback & Compliment';
      initialTeam = AppConstants.teamSupport;
    }

    final subj = item.title.trim().isNotEmpty
        ? item.title.trim()
        : (item.comment.trim().isNotEmpty
            ? (item.comment.length > 40 ? '${item.comment.substring(0, 40)}...' : item.comment)
            : 'Rating Feedback - Star ${item.rating}');

    final desc = item.comment.trim().isNotEmpty
        ? item.comment.trim()
        : 'User submitted a ${item.rating}-star review for Content ID: ${item.contentId}.';

    return SupportTicket(
      id: item.reviewId,
      ticketId: item.reviewId.toString(),
      ticketNumber: ticketNum,
      userId: item.userId,
      contentId: item.contentId,
      rating: item.rating,
      subject: subj,
      description: desc,
      createdAt: createdDate,
      status: initialStatus,
      priority: initialPriority,
      team: initialTeam,
      ticketOwner: 'Unassigned',
      currentAssignee: 'Unassigned',
      category: initialCategory,
      source: AppConstants.sourceFilmytell,
      customerName: 'User #${item.userId}',
      history: [
        TicketHistory(
          id: 'hist_init_${item.reviewId}',
          ticketId: item.reviewId.toString(),
          action: 'Ticket Created',
          description: 'Ticket automatically generated from Rating & Review (ID: ${item.reviewId})',
          performedBy: 'System Ingestion',
          timestamp: createdDate,
        ),
      ],
      messages: [
        TicketMessage(
          id: 'msg_init_${item.reviewId}',
          ticketId: item.reviewId.toString(),
          senderName: 'User #${item.userId}',
          senderRole: 'User',
          content: desc,
          type: MessageType.userMessage,
          timestamp: createdDate,
        ),
      ],
    );
  }

  SupportTicket copyWith({
    int? id,
    String? ticketId,
    String? ticketNumber,
    int? userId,
    int? contentId,
    int? rating,
    String? title,
    String? subject,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? priority,
    String? team,
    int? assignedTeamId,
    String? ticketOwner,
    int? ticketOwnerId,
    String? currentAssignee,
    int? currentAssigneeId,
    String? delegatedFrom,
    int? delegatedFromId,
    int? delegationLevel,
    String? category,
    String? subCategory,
    String? source,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? externalTicketId,
    DateTime? slaResponseDueAt,
    DateTime? slaResolutionDueAt,
    bool? slaBreached,
    bool? aiEligible,
    double? aiConfidence,
    bool? aiResolved,
    DateTime? resolvedAt,
    DateTime? closedAt,
    String? resolutionNotes,
    List<DelegationNode>? delegations,
    List<TicketHistory>? history,
    List<TicketMessage>? messages,
    List<TicketMessage>? notes,
    AiAnalysisResult? aiAnalysis,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      rating: rating ?? this.rating,
      subject: subject ?? title ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      team: team ?? this.team,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      ticketOwner: ticketOwner ?? this.ticketOwner,
      ticketOwnerId: ticketOwnerId ?? this.ticketOwnerId,
      currentAssignee: currentAssignee ?? this.currentAssignee,
      currentAssigneeId: currentAssigneeId ?? this.currentAssigneeId,
      delegatedFrom: delegatedFrom ?? this.delegatedFrom,
      delegatedFromId: delegatedFromId ?? this.delegatedFromId,
      delegationLevel: delegationLevel ?? this.delegationLevel,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      source: source ?? this.source,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      externalTicketId: externalTicketId ?? this.externalTicketId,
      slaResponseDueAt: slaResponseDueAt ?? this.slaResponseDueAt,
      slaResolutionDueAt: slaResolutionDueAt ?? this.slaResolutionDueAt,
      slaBreached: slaBreached ?? this.slaBreached,
      aiEligible: aiEligible ?? this.aiEligible,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiResolved: aiResolved ?? this.aiResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      delegations: delegations ?? this.delegations,
      history: history ?? this.history,
      messages: messages ?? this.messages,
      notes: notes ?? this.notes,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['ticketId'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final subj = json['subject']?.toString() ?? json['title']?.toString() ?? '';
    final assignedTeam = json['assignedTeamName']?.toString() ?? json['teamName']?.toString() ?? json['team']?.toString() ?? AppConstants.teamSupport;
    final owner = json['ticketOwnerName']?.toString() ?? json['ownerName']?.toString() ?? json['ticketOwner']?.toString() ?? 'Unassigned';
    final assignee = json['currentAssigneeName']?.toString() ?? json['assigneeName']?.toString() ?? json['currentAssignee']?.toString() ?? 'Unassigned';
    final delFrom = json['delegatedFromName']?.toString() ?? json['delegatedFrom']?.toString();
    final delLevel = json['activeDelegationLevel'] ?? json['delegationLevel'] ?? 0;

    // Parse tasks / delegations
    List<DelegationNode> parsedTasks = [];
    if (json['tasks'] is List) {
      parsedTasks = (json['tasks'] as List).map((e) => DelegationNode.fromJson(e as Map<String, dynamic>)).toList();
    } else if (json['delegations'] is List) {
      parsedTasks = (json['delegations'] as List).map((e) => DelegationNode.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Parse messages
    List<TicketMessage> parsedMessages = [];
    if (json['messages'] is List) {
      parsedMessages = (json['messages'] as List).map((e) => TicketMessage.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Parse internal notes
    List<TicketMessage> parsedNotes = [];
    if (json['notes'] is List) {
      parsedNotes = (json['notes'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        return TicketMessage(
          id: map['id']?.toString() ?? '',
          ticketId: parsedId.toString(),
          senderName: map['authorName']?.toString() ?? map['senderName']?.toString() ?? 'Staff',
          senderRole: 'Staff Note',
          content: map['note']?.toString() ?? map['content']?.toString() ?? '',
          type: MessageType.internalNote,
          timestamp: parseDate(map['createdAt'], DateTime.now()),
        );
      }).toList();
    }

    // Parse history
    List<TicketHistory> parsedHistory = [];
    if (json['history'] is List) {
      parsedHistory = (json['history'] as List).map((e) => TicketHistory.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SupportTicket(
      id: parsedId,
      ticketId: parsedId.toString(),
      ticketNumber: json['ticketNumber']?.toString() ?? 'FT-0000',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      contentId: json['contentId'] is int ? json['contentId'] : int.tryParse(json['contentId']?.toString() ?? '0') ?? 0,
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      subject: subj,
      description: json['description']?.toString() ?? '',
      createdAt: parseDate(json['createdAt'], DateTime.now()),
      updatedAt: parseNullableDate(json['updatedAt']),
      status: json['status']?.toString() ?? AppConstants.statusNew,
      priority: json['priority']?.toString() ?? AppConstants.priorityMedium,
      team: assignedTeam,
      assignedTeamId: json['assignedTeamId'] is int ? json['assignedTeamId'] : int.tryParse(json['assignedTeamId']?.toString() ?? ''),
      ticketOwner: owner,
      ticketOwnerId: json['ticketOwnerId'] is int ? json['ticketOwnerId'] : int.tryParse(json['ticketOwnerId']?.toString() ?? ''),
      currentAssignee: assignee,
      currentAssigneeId: json['currentAssigneeId'] is int ? json['currentAssigneeId'] : int.tryParse(json['currentAssigneeId']?.toString() ?? ''),
      delegatedFrom: delFrom,
      delegatedFromId: json['delegatedFromId'] is int ? json['delegatedFromId'] : int.tryParse(json['delegatedFromId']?.toString() ?? ''),
      delegationLevel: delLevel is int ? delLevel : int.tryParse(delLevel.toString()) ?? 0,
      category: json['category']?.toString() ?? 'General',
      subCategory: json['subCategory']?.toString(),
      source: json['sourcePortal']?.toString() ?? json['source']?.toString() ?? AppConstants.sourceFilmytell,
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      customerPhone: json['customerPhone']?.toString() ?? json['customerId']?.toString(),
      externalTicketId: json['externalTicketId']?.toString(),
      slaResponseDueAt: parseNullableDate(json['slaResponseDueAt']),
      slaResolutionDueAt: parseNullableDate(json['slaResolutionDueAt']),
      slaBreached: json['slaBreached'] is bool ? json['slaBreached'] : false,
      aiEligible: json['aiEligible'] is bool ? json['aiEligible'] : false,
      aiConfidence: json['aiConfidence'] is num ? (json['aiConfidence'] as num).toDouble() : double.tryParse(json['aiConfidence']?.toString() ?? ''),
      aiResolved: json['aiResolved'] is bool ? json['aiResolved'] : false,
      resolvedAt: parseNullableDate(json['resolvedAt']),
      closedAt: parseNullableDate(json['closedAt']),
      resolutionNotes: json['resolutionNotes']?.toString(),
      delegations: parsedTasks,
      history: parsedHistory,
      messages: parsedMessages,
      notes: parsedNotes,
      aiAnalysis: json['aiAnalysis'] != null ? AiAnalysisResult.fromJson(json['aiAnalysis'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'ticketNumber': ticketNumber,
      'userId': userId,
      'contentId': contentId,
      'rating': rating,
      'subject': subject,
      'title': subject,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'priority': priority,
      'team': team,
      'assignedTeamId': assignedTeamId,
      'assignedTeamName': team,
      'ticketOwner': ticketOwner,
      'ticketOwnerId': ticketOwnerId,
      'ticketOwnerName': ticketOwner,
      'currentAssignee': currentAssignee,
      'currentAssigneeId': currentAssigneeId,
      'currentAssigneeName': currentAssignee,
      'delegatedFrom': delegatedFrom,
      'delegatedFromId': delegatedFromId,
      'delegatedFromName': delegatedFrom,
      'delegationLevel': delegationLevel,
      'activeDelegationLevel': delegationLevel,
      'category': category,
      'subCategory': subCategory,
      'source': source,
      'sourcePortal': source,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'externalTicketId': externalTicketId,
      'slaResponseDueAt': slaResponseDueAt?.toIso8601String(),
      'slaResolutionDueAt': slaResolutionDueAt?.toIso8601String(),
      'slaBreached': slaBreached,
      'aiEligible': aiEligible,
      'aiConfidence': aiConfidence,
      'aiResolved': aiResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
      'delegations': delegations.map((e) => e.toJson()).toList(),
      'tasks': delegations.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
      'messages': messages.map((e) => e.toJson()).toList(),
      'aiAnalysis': aiAnalysis?.toJson(),
    };
  }
}
