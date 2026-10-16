class TicketHistory {
  final String id;
  final String ticketId;
  final String action; // Status change, Priority change, Assigned, Delegated, Note added, etc.
  final String description;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  TicketHistory({
    required this.id,
    required this.ticketId,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
  });

  factory TicketHistory.fromJson(Map<String, dynamic> json) {
    String act = json['action']?.toString() ?? '';
    if (act.isEmpty && json['eventType'] != null) {
      final evt = json['eventType'].toString();
      act = evt.replaceAll('_', ' ').toLowerCase();
      // Capitalize words
      act = act.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    if (act.isEmpty) act = 'Ticket Event';

    final byUser = json['performedByUserName']?.toString() ??
        json['performedBy']?.toString() ??
        'System';

    return TicketHistory(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      action: act,
      description: json['description']?.toString() ?? '',
      performedBy: byUser,
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now()),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'action': action,
      'description': description,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
