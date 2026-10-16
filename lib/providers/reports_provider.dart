import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/support_ticket_model.dart';
import '../services/dashboard_api_service.dart';
import 'ticket_provider.dart';

class ReportsProvider extends ChangeNotifier {
  final TicketProvider _ticketProvider;
  final DashboardApiService _dashboardApiService;

  DashboardSummaryData? _serverSummary;
  bool _isLoading = false;

  ReportsProvider(
    this._ticketProvider, {
    DashboardApiService? dashboardApiService,
  }) : _dashboardApiService = dashboardApiService ?? DashboardApiService();

  List<SupportTicket> get _tickets => _ticketProvider.allTickets;
  DashboardSummaryData? get serverSummary => _serverSummary;
  bool get isLoading => _isLoading;

  Future<void> loadServerSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final summary = await _dashboardApiService.getDashboardSummary();
      if (summary != null) {
        _serverSummary = summary;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // 1. Volume by Status
  Map<String, int> get statusDistribution {
    if (_serverSummary != null && _serverSummary!.ticketsByStatus.isNotEmpty) {
      return _serverSummary!.ticketsByStatus;
    }

    final Map<String, int> map = {
      for (var s in AppConstants.allStatuses) s: 0,
    };
    for (var t in _tickets) {
      map[t.status] = (map[t.status] ?? 0) + 1;
    }
    return map;
  }

  // 2. Volume by Priority
  Map<String, int> get priorityDistribution {
    if (_serverSummary != null && _serverSummary!.ticketsByPriority.isNotEmpty) {
      return _serverSummary!.ticketsByPriority;
    }

    final Map<String, int> map = {
      for (var p in AppConstants.allPriorities) p: 0,
    };
    for (var t in _tickets) {
      map[t.priority] = (map[t.priority] ?? 0) + 1;
    }
    return map;
  }

  // 3. Team Workload
  Map<String, int> get teamDistribution {
    final Map<String, int> map = {
      AppConstants.teamSupport: 0,
      AppConstants.teamTechnical: 0,
    };
    for (var t in _tickets) {
      if (map.containsKey(t.team)) {
        map[t.team] = map[t.team]! + 1;
      }
    }
    return map;
  }

  // 4. Delegation Metrics
  int get totalDelegatedTickets => _serverSummary?.totalDelegatedTasks ?? _tickets.where((t) => t.delegations.isNotEmpty).length;
  int get totalDelegationEvents => _tickets.fold(0, (sum, t) => sum + t.delegations.length);

  Map<String, int> get delegationDepthDistribution {
    final map = {
      'Level 0 (Direct)': 0,
      'Level 1 (A → B)': 0,
      'Level 2 (A → B → C)': 0,
      'Level 3+ (Deep)': 0,
    };

    for (var t in _tickets) {
      if (t.delegations.isEmpty) {
        map['Level 0 (Direct)'] = map['Level 0 (Direct)']! + 1;
      } else if (t.delegationLevel == 1) {
        map['Level 1 (A → B)'] = map['Level 1 (A → B)']! + 1;
      } else if (t.delegationLevel == 2) {
        map['Level 2 (A → B → C)'] = map['Level 2 (A → B → C)']! + 1;
      } else {
        map['Level 3+ (Deep)'] = map['Level 3+ (Deep)']! + 1;
      }
    }
    return map;
  }

  // 5. SLA Performance
  double get slaComplianceRate {
    final resolvedOrClosed = _tickets.where((t) => t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed).toList();
    if (resolvedOrClosed.isEmpty) return 0.0;
    int onTime = 0;
    for (var t in resolvedOrClosed) {
      if (!t.slaBreached) onTime++;
    }
    return ((onTime / resolvedOrClosed.length) * 100).clamp(0, 100);
  }

  double get averageTurnaroundHours {
    if (_serverSummary != null && _serverSummary!.averageResolutionTimeMinutes > 0) {
      return _serverSummary!.averageResolutionTimeMinutes / 60.0;
    }
    return 0.0;
  }

  double get aiResolutionRate {
    if (_serverSummary != null && _serverSummary!.totalTickets > 0) {
      return ((_serverSummary!.aiResolvedTickets / _serverSummary!.totalTickets) * 100).clamp(0, 100);
    }
    return 0.0;
  }

  // 6. Source Distribution
  Map<String, int> get sourceDistribution {
    if (_serverSummary != null && _serverSummary!.ticketsBySourcePortal.isNotEmpty) {
      return _serverSummary!.ticketsBySourcePortal;
    }

    final Map<String, int> map = {
      AppConstants.sourceFilmytell: 0,
      AppConstants.sourcePartner: 0,
    };
    for (var t in _tickets) {
      map[t.source] = (map[t.source] ?? 0) + 1;
    }
    return map;
  }
}
