class AppConstants {
  static const String appName = 'Filmytell Help & Support';
  static const String appVersion = '1.0.0';

  // Seed Backend Credentials
  static const String defaultAdminEmail = 'admin@filmytell.com';
  static const String defaultAdminPassword = 'Password@123';
  static const String defaultAdminName = 'Admin User';
  static const String defaultAdminRole = 'ROLE_ADMIN';

  // Storage Keys
  static const String keyUserSession = 'filmytell_user_session';
  static const String keyAccessToken = 'filmytell_access_token';
  static const String keyRefreshToken = 'filmytell_refresh_token';
  static const String keyLocalTickets = 'filmytell_local_tickets';
  static const String keyLocalUsers = 'filmytell_local_users';
  static const String keyTeamMembers = 'filmytell_team_members';
  static const String keyKbArticles = 'filmytell_kb_articles';
  static const String keyAiSettings = 'filmytell_ai_settings';
  static const String keySlaSettings = 'filmytell_sla_settings';

  // Ticket Statuses (Spring Boot Backend enum values)
  static const String statusNew = 'NEW';
  static const String statusAiAnalysis = 'AI_ANALYSIS';
  static const String statusAiResolved = 'AI_RESOLVED';
  static const String statusAssigned = 'ASSIGNED';
  static const String statusInProgress = 'IN_PROGRESS';
  static const String statusPendingUser = 'PENDING_USER';
  static const String statusResolved = 'RESOLVED';
  static const String statusClosed = 'CLOSED';

  static const List<String> allStatuses = [
    statusNew,
    statusAiAnalysis,
    statusAiResolved,
    statusAssigned,
    statusInProgress,
    statusPendingUser,
    statusResolved,
    statusClosed,
  ];

  static String statusTitle(String status) {
    switch (status) {
      case statusNew:
        return 'NEW';
      case statusAiAnalysis:
      case 'AI ANALYSIS':
        return 'AI ANALYSIS';
      case statusAiResolved:
      case 'AI RESOLVED':
        return 'AI RESOLVED';
      case statusAssigned:
        return 'ASSIGNED';
      case statusInProgress:
      case 'IN PROGRESS':
        return 'IN PROGRESS';
      case statusPendingUser:
      case 'PENDING USER':
        return 'PENDING USER';
      case statusResolved:
        return 'RESOLVED';
      case statusClosed:
        return 'CLOSED';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  // Priorities
  static const String priorityUrgent = 'URGENT';
  static const String priorityHigh = 'HIGH';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityLow = 'LOW';

  static const List<String> allPriorities = [
    priorityUrgent,
    priorityHigh,
    priorityMedium,
    priorityLow,
  ];

  // Teams
  static const String teamSupport = 'Support Team';
  static const String teamTechnical = 'Technical Support Team';

  static const List<String> allTeams = [
    teamSupport,
    teamTechnical,
  ];

  // Portals / Sources
  static const String sourceFilmytell = 'FILMYTELL';
  static const String sourcePartner = 'FILMYTELL_PARTNER';
  static const String sourceProduction = 'PRODUCTION_HOUSE';

  static const List<String> allSources = [
    sourceFilmytell,
    sourcePartner,
    sourceProduction,
  ];

  static String sourceTitle(String source) {
    switch (source) {
      case sourceFilmytell:
      case 'Filmytell':
        return 'Filmytell';
      case sourcePartner:
      case 'Filmytell Partner':
        return 'Filmytell Partner';
      case sourceProduction:
      case 'Production House Portal':
        return 'Production House';
      default:
        return source.replaceAll('_', ' ');
    }
  }

  // Delegation Reasons
  static const String reasonExpertise = 'EXPERTISE';
  static const String reasonWorkload = 'WORKLOAD';
  static const String reasonAvailability = 'AVAILABILITY';
  static const String reasonTechDependency = 'TECHNICAL_DEPENDENCY';
  static const String reasonShiftHandover = 'SHIFT_HANDOVER';
  static const String reasonOther = 'OTHER';

  static const List<String> delegationReasons = [
    reasonExpertise,
    reasonWorkload,
    reasonAvailability,
    reasonTechDependency,
    reasonShiftHandover,
    reasonOther,
  ];

  static String reasonTitle(String reason) {
    switch (reason) {
      case reasonExpertise:
        return 'Expertise Required';
      case reasonWorkload:
        return 'High Workload';
      case reasonAvailability:
        return 'Agent Availability';
      case reasonTechDependency:
        return 'Technical Dependency';
      case reasonShiftHandover:
        return 'Shift Handover';
      case reasonOther:
        return 'Other';
      default:
        return reason.replaceAll('_', ' ');
    }
  }

  // Delegation Task Statuses
  static const String taskPending = 'PENDING';
  static const String taskInProgress = 'IN_PROGRESS';
  static const String taskCompleted = 'COMPLETED';
  static const String taskReturned = 'RETURNED';
  static const String taskCancelled = 'CANCELLED';

  // Aliases for backward compatibility
  static const String delegationPending = 'PENDING';
  static const String delegationInProgress = 'IN_PROGRESS';
  static const String delegationCompleted = 'COMPLETED';
  static const String delegationReturned = 'RETURNED';
  static const String delegationCancelled = 'CANCELLED';

  static const List<String> allTaskStatuses = [
    taskPending,
    taskInProgress,
    taskCompleted,
    taskReturned,
    taskCancelled,
  ];
}
