import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/team_member_model.dart';
import '../repositories/team_repository.dart';

class TeamProvider extends ChangeNotifier {
  final TeamRepository _teamRepository;

  List<TeamMember> _members = [];
  bool _isLoading = false;
  String? _selectedTeamFilter;

  TeamProvider({TeamRepository? teamRepository})
      : _teamRepository = teamRepository ?? TeamRepository() {
    loadMembers();
  }

  List<TeamMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get selectedTeamFilter => _selectedTeamFilter;

  List<TeamMember> get supportTeamMembers =>
      _members.where((m) => m.team == AppConstants.teamSupport).toList();

  List<TeamMember> get technicalTeamMembers =>
      _members.where((m) => m.team == AppConstants.teamTechnical).toList();

  List<TeamMember> get filteredMembers {
    if (_selectedTeamFilter == null || _selectedTeamFilter!.isEmpty || _selectedTeamFilter == 'All') {
      return _members;
    }
    return _members.where((m) => m.team == _selectedTeamFilter).toList();
  }

  Future<void> loadMembers({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _members = await _teamRepository.getTeamMembers(forceRefresh: forceRefresh);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTeamFilter(String? team) {
    _selectedTeamFilter = team;
    notifyListeners();
  }

  Future<void> addMember(TeamMember member) async {
    await _teamRepository.addMember(member);
    await loadMembers();
  }

  Future<void> updateMember(TeamMember member) async {
    await _teamRepository.updateMember(member);
    await loadMembers();
  }

  Future<void> toggleAvailability(String memberId) async {
    await _teamRepository.toggleAvailability(memberId);
    await loadMembers();
  }
}
