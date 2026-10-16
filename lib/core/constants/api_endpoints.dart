class ApiEndpoints {
  /// Base URL dynamically resolved from compile-time environment flags
  /// Development: defaults to http://localhost:8080
  /// Production: configured via --dart-define=API_BASE_URL=https://help-api.filmytell.com
  static const String baseUrl = bool.hasEnvironment('API_BASE_URL')
      ? String.fromEnvironment('API_BASE_URL')
      : String.fromEnvironment(
          'BACKEND_URL',
          defaultValue: 'http://13.201.27.141:8080/help-support-backend',
        );

  // Legacy / External
  static const String ratingAndReviewGetAll =
      'https://filmytell.com/ott/api/TicketRaised/getAllTicketRaised';

  // Auth
  static const String login = '$baseUrl/api/v1/auth/login';
  static const String refresh = '$baseUrl/api/v1/auth/refresh';
  static const String register = '$baseUrl/api/v1/auth/register';

  // Tickets
  static const String tickets = '$baseUrl/api/v1/tickets';
  static const String ticketSync = '$baseUrl/api/v1/tickets/sync';
  static String ticketDetails(dynamic id) => '$baseUrl/api/v1/tickets/$id';
  static String ticketAssign(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/assign';
  static String ticketTransferOwnership(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/transfer-ownership';
  static String ticketStatus(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/status';
  static String ticketPriority(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/priority';
  static String ticketResolve(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/resolve';
  static String ticketClose(dynamic id) => '$baseUrl/api/v1/tickets/$id/close';
  static String ticketReopen(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/reopen';

  // Tasks & Multi-Level Delegation
  static String ticketDelegate(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/delegate';
  static String ticketTasks(dynamic id) => '$baseUrl/api/v1/tickets/$id/tasks';
  static String taskStart(dynamic taskId) =>
      '$baseUrl/api/v1/tasks/$taskId/start';
  static String taskComplete(dynamic taskId) =>
      '$baseUrl/api/v1/tasks/$taskId/complete';
  static String taskReturn(dynamic taskId) =>
      '$baseUrl/api/v1/tasks/$taskId/return';
  static String taskOverride(dynamic taskId) =>
      '$baseUrl/api/v1/tasks/$taskId/override';

  // Kanban
  static const String kanban = '$baseUrl/api/v1/kanban';

  // Conversation & Notes
  static String ticketMessages(dynamic id) =>
      '$baseUrl/api/v1/tickets/$id/messages';
  static String ticketNotes(dynamic id) => '$baseUrl/api/v1/tickets/$id/notes';

  // Dashboard & Metrics
  static const String dashboardSummary = '$baseUrl/api/v1/dashboard/summary';
  static const String dashboardTeamWorkload =
      '$baseUrl/api/v1/dashboard/team-workload';

  // Notifications
  static const String notifications = '$baseUrl/api/v1/notifications';
  static String notificationRead(dynamic id) =>
      '$baseUrl/api/v1/notifications/$id/read';
  static const String notificationReadAll =
      '$baseUrl/api/v1/notifications/read-all';

  // Teams
  static const String teams = '$baseUrl/api/v1/teams';
  static String teamDetails(dynamic id) => '$baseUrl/api/v1/teams/$id';
  static String teamMembers(dynamic id) => '$baseUrl/api/v1/teams/$id/members';
  static String teamMemberDelete(dynamic teamId, dynamic userId) =>
      '$baseUrl/api/v1/teams/$teamId/members/$userId';

  // Users & Staff Agents
  static const String users = '$baseUrl/api/v1/users';
  static const String activeAgents = '$baseUrl/api/v1/users/agents';
  static const String currentUser = '$baseUrl/api/v1/users/me';
  static String userDetails(dynamic id) => '$baseUrl/api/v1/users/$id';
  static String userStatus(dynamic id) => '$baseUrl/api/v1/users/$id/status';
}
