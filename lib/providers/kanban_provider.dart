import 'package:flutter/material.dart';
import '../models/support_ticket_model.dart';
import '../services/kanban_api_service.dart';
import 'ticket_provider.dart';

class KanbanProvider extends ChangeNotifier {
  final TicketProvider _ticketProvider;
  final KanbanApiService _kanbanApiService;

  String? _teamFilter;
  String? _priorityFilter;
  String? _sourcePortalFilter;
  String? _searchQuery;

  bool _isLoading = false;
  String? _errorMessage;
  KanbanBoardData? _boardData;

  // Local optimistic overrides map: ticketId -> optimisticStatus
  final Map<String, String> _optimisticStatusOverrides = {};

  KanbanProvider(
    this._ticketProvider, {
    KanbanApiService? kanbanApiService,
  }) : _kanbanApiService = kanbanApiService ?? KanbanApiService();

  String? get teamFilter => _teamFilter;
  String? get priorityFilter => _priorityFilter;
  String? get sourcePortalFilter => _sourcePortalFilter;
  String? get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setTeamFilter(String? team) {
    _teamFilter = team;
    notifyListeners();
    loadBoard();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
    loadBoard();
  }

  void setSourcePortalFilter(String? source) {
    _sourcePortalFilter = source;
    notifyListeners();
    loadBoard();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
    loadBoard();
  }

  Future<void> loadBoard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _kanbanApiService.getKanbanBoard(
        priority: _priorityFilter,
        sourcePortal: _sourcePortalFilter,
        search: _searchQuery,
      );
      if (data.columns.isNotEmpty) {
        _boardData = data;
        _optimisticStatusOverrides.clear();
      }
    } catch (e) {
      // Backend offline or fallback to TicketProvider
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<SupportTicket> getTicketsForColumn(String status) {
    // If backend board data is available, check it first
    if (_boardData != null && _boardData!.columns.isNotEmpty) {
      final col = _boardData!.columns.firstWhere(
        (c) => c.status == status,
        orElse: () => KanbanColumnData(status: status, title: status, count: 0, tickets: []),
      );

      // Apply optimistic overrides
      final list = List<SupportTicket>.from(col.tickets);
      
      // Remove any ticket that was optimistically moved away
      list.removeWhere((t) {
        final override = _optimisticStatusOverrides[t.ticketId];
        return override != null && override != status;
      });

      // Add any ticket that was optimistically moved into this column
      for (final entry in _optimisticStatusOverrides.entries) {
        if (entry.value == status && !list.any((t) => t.ticketId == entry.key)) {
          try {
            final ticket = _ticketProvider.allTickets.firstWhere(
              (t) => t.ticketId == entry.key,
            );
            list.add(ticket.copyWith(status: status));
          } catch (_) {
            // If not found in ticket list, do not fabricate fake ticket
          }
        }
      }

      return list;
    }

    // Fallback: Compute from TicketProvider
    return _ticketProvider.allTickets.where((ticket) {
      final effectiveStatus = _optimisticStatusOverrides[ticket.ticketId] ?? ticket.status;
      if (effectiveStatus != status) return false;
      if (_teamFilter != null && _teamFilter!.isNotEmpty && _teamFilter != 'All') {
        if (ticket.team != _teamFilter) return false;
      }
      if (_priorityFilter != null && _priorityFilter!.isNotEmpty && _priorityFilter != 'All') {
        if (ticket.priority != _priorityFilter) return false;
      }
      return true;
    }).toList();
  }

  /// Optimistic Drag & Drop with automatic rollback on API rejection
  Future<bool> moveTicket(
    SupportTicket ticket,
    String targetStatus,
    String performedBy,
  ) async {
    if (ticket.status == targetStatus) return true;

    final originalStatus = ticket.status;
    _errorMessage = null;

    // 1. Optimistic Update immediately in UI
    _optimisticStatusOverrides[ticket.ticketId] = targetStatus;
    notifyListeners();

    try {
      // 2. Call backend mutation
      await _ticketProvider.updateTicketStatus(
        ticket.ticketId,
        targetStatus,
        performedBy,
        notes: 'Moved via Kanban Drag & Drop from $originalStatus to $targetStatus',
      );

      // 3. Success -> Clear override and sync board
      _optimisticStatusOverrides.remove(ticket.ticketId);
      await loadBoard();
      return true;
    } catch (e) {
      // 4. Rollback on failure!
      _optimisticStatusOverrides.remove(ticket.ticketId);
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }
}
