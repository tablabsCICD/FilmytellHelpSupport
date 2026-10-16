import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/team_member_model.dart';

class TeamUserApiService {
  final ApiClient _apiClient;

  TeamUserApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get active support agents and staff for assignment and delegation
  Future<List<TeamMember>> getActiveAgents() async {
    try {
      debugPrint('[GET ACTIVE AGENTS REQUEST] -> ${ApiEndpoints.activeAgents}');
      final responseJson = await _apiClient.get(ApiEndpoints.activeAgents);
      debugPrint('[GET ACTIVE AGENTS RESPONSE] -> $responseJson');
      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'];
        if (data is List) {
          return data.map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('[GET ACTIVE AGENTS ERROR] -> $e');
    }
    return [];
  }

  /// Get list of all support teams and nested members
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.teams);
      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Add member to team
  Future<bool> addMemberToTeam(int teamId, {required int userId, String roleInTeam = 'MEMBER'}) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.teamMembers(teamId),
        body: {
          'userId': userId,
          'roleInTeam': roleInTeam,
        },
      );
      return responseJson != null;
    } catch (_) {
      return false;
    }
  }

  /// Remove/deactivate member from team
  Future<bool> removeMemberFromTeam(int teamId, int userId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamMemberDelete(teamId, userId));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get all registered users (Admin only)
  Future<List<TeamMember>> getAllUsers() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.users);
      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'];
        if (data is List) {
          return data.map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Activate or deactivate user account
  Future<bool> toggleUserStatus(int userId, bool active) async {
    try {
      final responseJson = await _apiClient.patch(
        ApiEndpoints.userStatus(userId),
        queryParameters: {'active': active},
      );
      return responseJson != null;
    } catch (_) {
      return false;
    }
  }

  /// Create / Register a new user agent on backend with debug logging
  Future<TeamMember?> createUser({
    required String name,
    required String email,
    required String role,
    required String team,
    required List<String> expertise,
    String? username,
  }) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : name;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Agent';

    String computedUsername = (username ?? '').trim();
    if (computedUsername.isEmpty) {
      // Derive from full name (e.g. "shiv_navale")
      computedUsername = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      if (computedUsername.startsWith('_')) computedUsername = computedUsername.substring(1);
      if (computedUsername.endsWith('_')) computedUsername = computedUsername.substring(0, computedUsername.length - 1);

      // If still less than 3 characters, use email prefix with suffix
      if (computedUsername.length < 3) {
        final emailPrefix = email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
        computedUsername = emailPrefix.length >= 3 ? emailPrefix : '${emailPrefix}_agent';
      }

      // Safety fallback to guarantee min 3 chars
      if (computedUsername.length < 3) {
        computedUsername = 'agent_${DateTime.now().millisecondsSinceEpoch % 10000}';
      }

      // Guarantee max 50 chars
      if (computedUsername.length > 50) {
        computedUsername = computedUsername.substring(0, 50);
      }
    }

    final roles = role.toLowerCase().contains('admin')
        ? ['ROLE_ADMIN']
        : (role.toLowerCase().contains('tech')
            ? ['ROLE_TECHNICAL_SUPPORT_MEMBER']
            : ['ROLE_SUPPORT_MEMBER']);

    final int teamId = team.toLowerCase().contains('tech') ? 2 : 1;

    final requestBody = {
      'username': computedUsername,
      'email': email.trim(),
      'password': 'Password@123',
      'firstName': firstName,
      'lastName': lastName,
      'teamId': teamId,
      'roles': roles,
    };

    debugPrint('======================================================');
    debugPrint('🚀 [ADD TEAM MEMBER REQUEST]');
    debugPrint('Endpoint: POST ${ApiEndpoints.register}');
    debugPrint('Payload: $requestBody');
    debugPrint('======================================================');

    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.register,
        body: requestBody,
      );

      debugPrint('======================================================');
      debugPrint('✅ [ADD TEAM MEMBER RESPONSE]');
      debugPrint('Status/Body: $responseJson');
      debugPrint('======================================================');

      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'] ?? responseJson;
        if (data is Map<String, dynamic>) {
          return TeamMember.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('======================================================');
      debugPrint('❌ [ADD TEAM MEMBER ERROR]');
      debugPrint('Error: $e');
      debugPrint('======================================================');
      rethrow;
    }
    return null;
  }
}
