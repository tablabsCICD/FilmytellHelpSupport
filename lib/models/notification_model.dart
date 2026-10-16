class AppNotification {
  final int id;
  final int recipientUserId;
  final int? ticketId;
  final String type;
  final String channel;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientUserId,
    this.ticketId,
    required this.type,
    this.channel = 'IN_APP',
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    final rawRecip = json['recipientUserId'];
    final parsedRecip = rawRecip is int ? rawRecip : int.tryParse(rawRecip?.toString() ?? '0') ?? 0;

    final rawTicketId = json['ticketId'];
    final parsedTicketId = rawTicketId is int ? rawTicketId : int.tryParse(rawTicketId?.toString() ?? '');

    return AppNotification(
      id: parsedId,
      recipientUserId: parsedRecip,
      ticketId: parsedTicketId,
      type: json['type']?.toString() ?? 'GENERAL',
      channel: json['channel']?.toString() ?? 'IN_APP',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] is bool ? json['read'] : false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      'ticketId': ticketId,
      'type': type,
      'channel': channel,
      'title': title,
      'message': message,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    int? recipientUserId,
    int? ticketId,
    String? type,
    String? channel,
    String? title,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      ticketId: ticketId ?? this.ticketId,
      type: type ?? this.type,
      channel: channel ?? this.channel,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
