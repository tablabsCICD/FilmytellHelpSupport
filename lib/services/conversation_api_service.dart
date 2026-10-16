import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/ticket_message_model.dart';

class ConversationApiService {
  final ApiClient _apiClient;

  ConversationApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get public customer messages (and internal audit messages if allowed)
  Future<List<TicketMessage>> getMessages(dynamic ticketId, {bool includeInternal = true}) async {
    final responseJson = await _apiClient.get(
      ApiEndpoints.ticketMessages(ticketId),
      queryParameters: {'includeInternal': includeInternal},
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'];
      if (data is List) {
        return data.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Send message in ticket conversation
  Future<TicketMessage> sendMessage(
    dynamic ticketId, {
    required String message,
    String messageType = 'PUBLIC',
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketMessages(ticketId),
      body: {
        'message': message,
        'messageType': messageType,
      },
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      return TicketMessage.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to send message');
  }

  /// Get confidential internal notes for ticket
  Future<List<TicketMessage>> getInternalNotes(dynamic ticketId) async {
    final responseJson = await _apiClient.get(ApiEndpoints.ticketNotes(ticketId));

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'];
      if (data is List) {
        return data.map((e) {
          final map = e as Map<String, dynamic>;
          return TicketMessage(
            id: map['id']?.toString() ?? '',
            ticketId: ticketId.toString(),
            senderName: map['authorName']?.toString() ?? 'Support Staff',
            senderRole: 'Staff Note',
            content: map['note']?.toString() ?? '',
            type: MessageType.internalNote,
            timestamp: map['createdAt'] != null
                ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();
      }
    }
    return [];
  }

  /// Add confidential internal note to ticket (hidden from customers)
  Future<TicketMessage> addInternalNote(
    dynamic ticketId, {
    required String note,
  }) async {
    final responseJson = await _apiClient.post(
      ApiEndpoints.ticketNotes(ticketId),
      body: {'note': note},
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      final map = data as Map<String, dynamic>;
      return TicketMessage(
        id: map['id']?.toString() ?? '',
        ticketId: ticketId.toString(),
        senderName: map['authorName']?.toString() ?? 'Staff Note',
        senderRole: 'Staff Note',
        content: map['note']?.toString() ?? note,
        type: MessageType.internalNote,
        timestamp: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    }
    throw Exception('Failed to add internal note');
  }
}
