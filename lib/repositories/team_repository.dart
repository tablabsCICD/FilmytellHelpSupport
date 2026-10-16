import '../core/constants/app_constants.dart';
import '../models/team_member_model.dart';
import '../services/storage_service.dart';
import '../services/team_user_api_service.dart';

class TeamRepository {
  final StorageService _storageService;
  final TeamUserApiService _teamUserApiService;
  List<TeamMember> _members = [];

  TeamRepository({
    StorageService? storageService,
    TeamUserApiService? teamUserApiService,
  })  : _storageService = storageService ?? StorageService(),
        _teamUserApiService = teamUserApiService ?? TeamUserApiService();

  /// Fetch active agents strictly from backend API (Zero mock/static data)
  Future<List<TeamMember>> getTeamMembers({bool forceRefresh = false}) async {
    // 1. Clear any legacy cached mock data if forceRefresh requested
    if (forceRefresh) {
      await clearLocalRosterCache();
    }

    // 2. Fetch active agents live from backend API
    try {
      final remoteAgents = await _teamUserApiService.getActiveAgents();
      _members = remoteAgents;
      await _saveToStorage();
      return _members;
    } catch (_) {
      // If offline/error, load from persisted storage without injecting static data
      if (_members.isEmpty) {
        _members = await _loadFromStorage();
      }
      return _members;
    }
  }

  /// Get teams from backend API
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    return await _teamUserApiService.getAllTeams();
  }

  Future<List<TeamMember>> getMembersByTeam(String team) async {
    final all = await getTeamMembers();
    return all.where((m) => m.team == team && m.isAvailable).toList();
  }

  Future<void> addMember(TeamMember member) async {
    await _storageService.init();

    // Register member on backend API
    final created = await _teamUserApiService.createUser(
      name: member.name,
      email: member.email,
      role: member.role,
      team: member.team,
      expertise: member.expertise,
    );

    if (created != null) {
      final existingIdx = _members.indexWhere((m) =>
          (m.email.isNotEmpty && m.email.toLowerCase() == created.email.toLowerCase()) ||
          m.id == created.id);
      if (existingIdx != -1) {
        _members[existingIdx] = created;
      } else {
        _members.add(created);
      }
      await _saveToStorage();
    } else {
      throw Exception('Failed to create team member on backend API');
    }
  }

  Future<void> updateMember(TeamMember updated) async {
    final index = _members.indexWhere((m) => m.id == updated.id || (m.email.isNotEmpty && m.email.toLowerCase() == updated.email.toLowerCase()));
    if (index != -1) {
      _members[index] = updated;
      await _saveToStorage();
    }
  }

  Future<void> toggleAvailability(String memberId) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final newStatus = !_members[index].isAvailable;
      _members[index] = _members[index].copyWith(
        isAvailable: newStatus,
      );
      await _saveToStorage();

      final userId = _members[index].userIdInt;
      if (userId > 0) {
        try {
          await _teamUserApiService.toggleUserStatus(userId, newStatus);
        } catch (_) {}
      }
    }
  }

  /// Clear all local roster cache
  Future<void> clearLocalRosterCache() async {
    _members = [];
    await _storageService.init();
    await _storageService.remove(AppConstants.keyTeamMembers);
    await _storageService.remove(AppConstants.keyLocalUsers);
  }

  Future<List<TeamMember>> _loadFromStorage() async {
    try {
      await _storageService.init();
      final jsonList = _storageService.getJson(AppConstants.keyTeamMembers);
      if (jsonList is List && jsonList.isNotEmpty) {
        final List<TeamMember> loaded = [];
        for (final item in jsonList) {
          if (item is Map) {
            try {
              loaded.add(TeamMember.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
        return loaded;
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToStorage() async {
    final list = _members.map((m) => m.toJson()).toList();
    await _storageService.setJson(AppConstants.keyTeamMembers, list);
  }
}
