import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/sla_calculator.dart';
import '../models/support_ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../models/ai_analysis_model.dart';
import '../repositories/ticket_repository.dart';

enum TicketSortBy { newest, oldest, priorityHighToLow, slaUrgent }

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository;

  List<SupportTicket> _allTickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPriority;
  String? _filterTeam;
  String? _filterAssignee;
  String? _filterSource;
  String? _filterCategory;
  TicketSortBy _sortBy = TicketSortBy.newest;

  // Pagination states
  int _currentPage = 0;
  final int _pageSize = 8;

  SupportTicket? _selectedTicket;

  TicketProvider({TicketRepository? ticketRepository})
      : _ticketRepository = ticketRepository ?? TicketRepository() {
    loadTickets();
  }

  List<SupportTicket> get allTickets => _allTickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get filterStatus => _filterStatus;
  String? get filterPriority => _filterPriority;
  String? get filterTeam => _filterTeam;
  String? get filterAssignee => _filterAssignee;
  String? get filterSource => _filterSource;
  String? get filterCategory => _filterCategory;
  TicketSortBy get sortBy => _sortBy;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  SupportTicket? get selectedTicket => _selectedTicket;

  Future<void> loadTickets({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTickets = await _ticketRepository.getTickets(
        page: _currentPage,
        pageSize: _pageSize,
        forceRefresh: forceRefresh,
      );
      if (_selectedTicket != null) {
        _selectedTicket = _allTickets.firstWhere(
          (t) => t.ticketId == _selectedTicket!.ticketId,
          orElse: () => _selectedTicket!,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load tickets. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTicket(SupportTicket ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  void clearSelectedTicket() {
    _selectedTicket = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterPriority(String? priority) {
    _filterPriority = priority;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterTeam(String? team) {
    _filterTeam = team;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterAssignee(String? assignee) {
    _filterAssignee = assignee;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterSource(String? source) {
    _filterSource = source;
    _currentPage = 0;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    _currentPage = 0;
    notifyListeners();
  }

  void setSortBy(TicketSortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPriority = null;
    _filterTeam = null;
    _filterAssignee = null;
    _filterSource = null;
    _filterCategory = null;
    _sortBy = TicketSortBy.newest;
    _currentPage = 0;
    notifyListeners();
  }

  void setPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // Filtered Tickets
  List<SupportTicket> get filteredTickets {
    return _allTickets.where((ticket) {
      // Search
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchNum = ticket.ticketNumber.toLowerCase().contains(query);
        final matchTitle = ticket.title.toLowerCase().contains(query);
        final matchDesc = ticket.description.toLowerCase().contains(query);
        final matchUser = ticket.userId.toString().contains(query);
        final matchContent = ticket.contentId.toString().contains(query);
        final matchOwner = ticket.ticketOwner.toLowerCase().contains(query);
        final matchAssignee = ticket.currentAssignee.toLowerCase().contains(query);
        final matchTeam = ticket.team.toLowerCase().contains(query);

        if (!matchNum && !matchTitle && !matchDesc && !matchUser && !matchContent && !matchOwner && !matchAssignee && !matchTeam) {
          return false;
        }
      }

      // Status
      if (_filterStatus != null && _filterStatus!.isNotEmpty && _filterStatus != 'All') {
        if (ticket.status != _filterStatus) return false;
      }

      // Priority
      if (_filterPriority != null && _filterPriority!.isNotEmpty && _filterPriority != 'All') {
        if (ticket.priority != _filterPriority) return false;
      }

      // Team
      if (_filterTeam != null && _filterTeam!.isNotEmpty && _filterTeam != 'All') {
        if (ticket.team != _filterTeam) return false;
      }

      // Assignee
      if (_filterAssignee != null && _filterAssignee!.isNotEmpty && _filterAssignee != 'All') {
        if (ticket.currentAssignee != _filterAssignee && ticket.ticketOwner != _filterAssignee) return false;
      }

      // Source
      if (_filterSource != null && _filterSource!.isNotEmpty && _filterSource != 'All') {
        if (ticket.source != _filterSource) return false;
      }

      // Category
      if (_filterCategory != null && _filterCategory!.isNotEmpty && _filterCategory != 'All') {
        if (ticket.category != _filterCategory) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case TicketSortBy.newest:
            return b.createdAt.compareTo(a.createdAt);
          case TicketSortBy.oldest:
            return a.createdAt.compareTo(b.createdAt);
          case TicketSortBy.priorityHighToLow:
            const order = {
              AppConstants.priorityUrgent: 4,
              AppConstants.priorityHigh: 3,
              AppConstants.priorityMedium: 2,
              AppConstants.priorityLow: 1,
            };
            return (order[b.priority] ?? 0).compareTo(order[a.priority] ?? 0);
          case TicketSortBy.slaUrgent:
            final slaA = SlaCalculator.calculateDueDate(a.createdAt, a.priority);
            final slaB = SlaCalculator.calculateDueDate(b.createdAt, b.priority);
            return slaA.compareTo(slaB);
        }
      });
  }

  int get totalFilteredCount => filteredTickets.length;
  int get totalPages => (totalFilteredCount / _pageSize).ceil() == 0 ? 1 : (totalFilteredCount / _pageSize).ceil();

  List<SupportTicket> get paginatedFilteredTickets {
    final list = filteredTickets;
    final startIndex = _currentPage * _pageSize;
    if (startIndex >= list.length) {
      if (list.isEmpty) return [];
      return list.sublist(0, list.length.clamp(0, _pageSize));
    }
    final endIndex = (startIndex + _pageSize).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  // Dashboard Metrics
  int get totalTicketsCount => _allTickets.length;
  int get newTicketsCount => _allTickets.where((t) => t.status == AppConstants.statusNew).length;
  int get openTicketsCount => _allTickets.where((t) => t.status != AppConstants.statusResolved && t.status != AppConstants.statusClosed).length;
  int get inProgressCount => _allTickets.where((t) => t.status == AppConstants.statusInProgress).length;
  int get pendingUserCount => _allTickets.where((t) => t.status == AppConstants.statusPendingUser).length;
  int get resolvedCount => _allTickets.where((t) => t.status == AppConstants.statusResolved).length;
  int get closedCount => _allTickets.where((t) => t.status == AppConstants.statusClosed).length;
  int get urgentCount => _allTickets.where((t) => t.priority == AppConstants.priorityUrgent && t.status != AppConstants.statusClosed).length;

  int get slaBreachedCount {
    return _allTickets.where((t) {
      if (t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed) return false;
      return SlaCalculator.getSlaInfo(t.createdAt, t.priority, t.status).isBreached;
    }).length;
  }

  int get slaWarningCount {
    return _allTickets.where((t) {
      if (t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed) return false;
      return SlaCalculator.getSlaInfo(t.createdAt, t.priority, t.status).status == SlaStatus.warning;
    }).length;
  }

  // Actions
  Future<void> updateTicketStatus(String ticketId, String newStatus, String performedBy, {String? notes}) async {
    await _ticketRepository.updateTicketStatus(ticketId, newStatus, performedBy, notes: notes);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> updateTicketPriority(String ticketId, String newPriority, String performedBy) async {
    await _ticketRepository.updateTicketPriority(ticketId, newPriority, performedBy);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> assignTicket(
    String ticketId,
    String team,
    String memberName,
    String performedBy, {
    int? assigneeId,
    int? teamId,
  }) async {
    await _ticketRepository.assignTicket(
      ticketId,
      team,
      memberName,
      performedBy,
      assigneeId: assigneeId,
      teamId: teamId,
    );
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> delegateTask(
    String ticketId, {
    required String toUserName,
    required String reason,
    required String instructions,
    DateTime? dueAt,
    required String performedBy,
    int? assignToUserId,
  }) async {
    await _ticketRepository.delegateTask(
      ticketId,
      toUserName: toUserName,
      reason: reason,
      instructions: instructions,
      dueAt: dueAt,
      performedBy: performedBy,
      assignToUserId: assignToUserId,
    );
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> startTask(String ticketId, int taskId) async {
    await _ticketRepository.startTask(ticketId, taskId);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> completeDelegation(String ticketId, String delegationId, String completionNotes, String performedBy) async {
    await _ticketRepository.completeDelegation(ticketId, delegationId, completionNotes, performedBy);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> returnTask(String ticketId, int taskId, String returnReason, String performedBy) async {
    await _ticketRepository.returnTask(ticketId, taskId, returnReason, performedBy);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> transferOwnership(
    String ticketId,
    String newOwnerName,
    String performedBy, {
    int? newOwnerId,
  }) async {
    await _ticketRepository.transferOwnership(
      ticketId,
      newOwnerName,
      performedBy,
      newOwnerId: newOwnerId,
    );
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> addMessage(String ticketId, TicketMessage message) async {
    await _ticketRepository.addMessage(ticketId, message);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<void> setAiAnalysis(String ticketId, AiAnalysisResult analysis) async {
    await _ticketRepository.setAiAnalysis(ticketId, analysis);
    await loadTickets();
    if (_selectedTicket != null && (_selectedTicket!.ticketId == ticketId || _selectedTicket!.id.toString() == ticketId)) {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId) ?? _selectedTicket;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> syncAdminPortalTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summary = await _ticketRepository.syncTickets();
      await loadTickets(forceRefresh: true);
      return summary;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
