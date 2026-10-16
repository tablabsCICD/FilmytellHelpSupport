import '../core/constants/app_constants.dart';
import '../models/support_ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../models/ai_analysis_model.dart';
import '../services/storage_service.dart';
import '../services/ticket_api_service.dart';
import '../services/task_api_service.dart';
import '../services/conversation_api_service.dart';

class TicketRepository {
  final TicketApiService _apiService;
  final TaskApiService _taskApiService;
  final ConversationApiService _conversationApiService;
  final StorageService _storageService;

  List<SupportTicket> _cachedTickets = [];
  int _totalElements = 0;
  int _totalPages = 1;

  TicketRepository({
    TicketApiService? apiService,
    TaskApiService? taskApiService,
    ConversationApiService? conversationApiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? TicketApiService(),
        _taskApiService = taskApiService ?? TaskApiService(),
        _conversationApiService = conversationApiService ?? ConversationApiService(),
        _storageService = storageService ?? StorageService();

  int get totalElements => _totalElements;
  int get totalPages => _totalPages;

  /// Fetch tickets from backend API. Zero dummy/seed data.
  Future<List<SupportTicket>> getTickets({
    int page = 0,
    int pageSize = 20,
    String? search,
    String? status,
    String? priority,
    String? sourcePortal,
    int? teamId,
    int? ownerId,
    int? assigneeId,
    bool? slaBreached,
    bool? aiResolved,
    bool forceRefresh = false,
  }) async {
    try {
      final pageResponse = await _apiService.searchTickets(
        page: page,
        size: pageSize,
        search: search,
        status: status,
        priority: priority,
        sourcePortal: sourcePortal,
        teamId: teamId,
        ownerId: ownerId,
        assigneeId: assigneeId,
        slaBreached: slaBreached,
        aiResolved: aiResolved,
      );

      _totalElements = pageResponse.totalElements;
      _totalPages = pageResponse.totalPages;
      _cachedTickets = pageResponse.content;
      await _saveToStorage();
      return _cachedTickets;
    } catch (e) {
      if (_cachedTickets.isEmpty) {
        final localData = await _storageService.getJson(AppConstants.keyLocalTickets);
        if (localData != null && localData is List && localData.isNotEmpty) {
          _cachedTickets = localData
              .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
              .toList();
          _totalElements = _cachedTickets.length;
          _totalPages = 1;
          return _cachedTickets;
        }
      }
      return _cachedTickets;
    }
  }

  /// Get ticket details strictly from backend API
  Future<SupportTicket?> getTicketById(String ticketId) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0) {
      try {
        final detail = await _apiService.getTicketDetails(intId);
        final index = _cachedTickets.indexWhere((t) => t.ticketId == ticketId || t.id == intId);
        if (index != -1) {
          _cachedTickets[index] = detail;
        } else {
          _cachedTickets.add(detail);
        }
        await _saveToStorage();
        return detail;
      } catch (_) {
        // Fall back to memory cache if API was previously loaded
      }
    }

    try {
      return _cachedTickets.firstWhere((t) => t.ticketId == ticketId || (intId != null && t.id == intId));
    } catch (_) {
      return null;
    }
  }

  /// Update ticket status via backend API
  Future<void> updateTicketStatus(
    String ticketId,
    String newStatus,
    String performedBy, {
    String? notes,
  }) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0) {
      final updatedTicket = await _apiService.updateStatus(intId, status: newStatus, reason: notes);
      final idx = _cachedTickets.indexWhere((t) => t.id == intId || t.ticketId == ticketId);
      if (idx != -1) {
        _cachedTickets[idx] = updatedTicket;
      } else {
        _cachedTickets.add(updatedTicket);
      }
      await _saveToStorage();
      return;
    }

    throw Exception('Invalid ticket ID: $ticketId');
  }

  /// Update ticket priority via backend API
  Future<void> updateTicketPriority(
    String ticketId,
    String newPriority,
    String performedBy,
  ) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0) {
      final updatedTicket = await _apiService.updatePriority(
        intId,
        priority: newPriority,
        reason: 'Priority updated by $performedBy',
      );
      final idx = _cachedTickets.indexWhere((t) => t.id == intId || t.ticketId == ticketId);
      if (idx != -1) {
        _cachedTickets[idx] = updatedTicket;
      } else {
        _cachedTickets.add(updatedTicket);
      }
      await _saveToStorage();
      return;
    }

    throw Exception('Invalid ticket ID: $ticketId');
  }

  /// Assign ticket via backend API
  Future<void> assignTicket(
    String ticketId,
    String team,
    String memberName,
    String performedBy, {
    int? assigneeId,
    int? teamId,
  }) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0 && assigneeId != null && teamId != null) {
      final updatedTicket = await _apiService.assignTicket(
        intId,
        assigneeId: assigneeId,
        teamId: teamId,
        reason: 'Assigned by $performedBy',
      );
      final idx = _cachedTickets.indexWhere((t) => t.id == intId || t.ticketId == ticketId);
      if (idx != -1) {
        _cachedTickets[idx] = updatedTicket;
      } else {
        _cachedTickets.add(updatedTicket);
      }
      await _saveToStorage();
      return;
    }

    throw Exception('Assignment requires valid backend ticket ID, assigneeId, and teamId');
  }

  /// Delegate task via backend API
  Future<void> delegateTask(
    String ticketId, {
    required String toUserName,
    required String reason,
    required String instructions,
    DateTime? dueAt,
    required String performedBy,
    int? assignToUserId,
  }) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0 && assignToUserId != null && assignToUserId > 0) {
      await _taskApiService.delegateTask(
        intId,
        assignToUserId: assignToUserId,
        reason: reason,
        instructions: instructions,
        dueAt: dueAt,
      );
      // Synchronize updated ticket details directly from backend
      await getTicketById(ticketId);
      return;
    }

    throw Exception('Delegation requires a valid backend assignee user ID');
  }

  /// Start task via backend API
  Future<void> startTask(String ticketId, int taskId) async {
    if (taskId > 0) {
      await _taskApiService.startTask(taskId);
      await getTicketById(ticketId);
      return;
    }
    throw Exception('Invalid task ID: $taskId');
  }

  /// Complete task via backend API
  Future<void> completeDelegation(
    String ticketId,
    String delegationId,
    String completionNotes,
    String performedBy,
  ) async {
    final intTaskId = int.tryParse(delegationId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intTaskId != null && intTaskId > 0) {
      await _taskApiService.completeTask(intTaskId, completionNotes: completionNotes);
      await getTicketById(ticketId);
      return;
    }

    throw Exception('Invalid task ID for completion: $delegationId');
  }

  /// Return task via backend API
  Future<void> returnTask(
    String ticketId,
    int taskId,
    String returnReason,
    String performedBy,
  ) async {
    if (taskId > 0) {
      await _taskApiService.returnTask(taskId, returnReason: returnReason);
      await getTicketById(ticketId);
      return;
    }
    throw Exception('Invalid task ID for return: $taskId');
  }

  /// Transfer ownership via backend API
  Future<void> transferOwnership(
    String ticketId,
    String newOwnerName,
    String performedBy, {
    int? newOwnerId,
  }) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    if (intId != null && intId > 0 && newOwnerId != null && newOwnerId > 0) {
      final updated = await _apiService.transferOwnership(
        intId,
        newOwnerId: newOwnerId,
        reason: 'Ownership transferred by $performedBy',
      );
      final idx = _cachedTickets.indexWhere((t) => t.id == intId || t.ticketId == ticketId);
      if (idx != -1) {
        _cachedTickets[idx] = updated;
      } else {
        _cachedTickets.add(updated);
      }
      await _saveToStorage();
      return;
    }

    throw Exception('Transfer ownership requires a valid backend newOwnerId');
  }

  /// Send message or confidential note via backend API with local cache fallback
  Future<void> addMessage(String ticketId, TicketMessage message) async {
    final intId = int.tryParse(ticketId.replaceAll(RegExp(r'[^0-9]'), ''));

    bool backendSuccess = false;
    if (intId != null && intId > 0) {
      try {
        if (message.type == MessageType.internalNote) {
          await _conversationApiService.addInternalNote(intId, note: message.content);
        } else {
          await _conversationApiService.sendMessage(intId, message: message.content);
        }
        backendSuccess = true;
        await getTicketById(ticketId);
        return;
      } catch (_) {
        // Fallback to local storage if network request fails
      }
    }

    // Append to local ticket cache so message appears instantly in UI
    final idx = _cachedTickets.indexWhere((t) => t.ticketId == ticketId || t.id.toString() == ticketId || t.externalTicketId == ticketId);
    if (idx != -1) {
      final current = _cachedTickets[idx];
      final isNote = message.type == MessageType.internalNote;
      final updatedList = isNote
          ? (List<TicketMessage>.from(current.notes)..add(message))
          : (List<TicketMessage>.from(current.messages)..add(message));

      _cachedTickets[idx] = isNote
          ? current.copyWith(notes: updatedList)
          : current.copyWith(messages: updatedList);
      await _saveToStorage();
    } else if (!backendSuccess) {
      throw Exception('Failed to send message');
    }
  }

  Future<void> setAiAnalysis(String ticketId, AiAnalysisResult analysis) async {
    final index = _cachedTickets.indexWhere((t) => t.ticketId == ticketId);
    if (index == -1) return;

    final currentTicket = _cachedTickets[index];
    _cachedTickets[index] = currentTicket.copyWith(aiAnalysis: analysis);
    await _saveToStorage();
  }

  /// Trigger ticket synchronization with Admin Portal
  Future<Map<String, dynamic>> syncTickets() async {
    final result = await _apiService.syncTickets();
    await getTickets(forceRefresh: true);
    return result;
  }

  Future<void> _saveToStorage() async {
    final list = _cachedTickets.map((t) => t.toJson()).toList();
    await _storageService.setJson(AppConstants.keyLocalTickets, list);
  }
}
