enum MessageType {
  userMessage,
  supportReply,
  internalNote,
  aiResponse,
}

class TicketMessage {
  final String id;
  final String ticketId;
  final String senderName;
  final String senderRole;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final List<String>? attachments;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.timestamp,
    this.attachments,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    MessageType type = MessageType.supportReply;
    final typeStr = json['type']?.toString().toLowerCase() ??
        json['messageType']?.toString().toLowerCase() ??
        '';
    final senderType = json['senderType']?.toString().toUpperCase() ?? '';

    if (senderType == 'CUSTOMER' || typeStr.contains('user') || typeStr.contains('customer')) {
      type = MessageType.userMessage;
    } else if (senderType == 'AI_SYSTEM' || typeStr.contains('ai')) {
      type = MessageType.aiResponse;
    } else if (typeStr.contains('internal') || typeStr.contains('note')) {
      type = MessageType.internalNote;
    } else {
      type = MessageType.supportReply;
    }

    final role = json['senderRole']?.toString() ??
        (senderType == 'CUSTOMER'
            ? 'Customer'
            : (senderType == 'AI_SYSTEM' ? 'AI Assistant' : 'Support Staff'));

    final msgText = json['message']?.toString() ?? json['content']?.toString() ?? json['note']?.toString() ?? '';

    return TicketMessage(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? json['authorName']?.toString() ?? 'Support Agent',
      senderRole: role,
      content: msgText,
      type: type,
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now()),
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'message': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': timestamp.toIso8601String(),
      'attachments': attachments,
    };
  }
}
