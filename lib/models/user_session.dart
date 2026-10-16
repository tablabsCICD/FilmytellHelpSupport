class UserSession {
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final List<String> permissions;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String team;
  final DateTime loggedInAt;

  UserSession({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    this.permissions = const [],
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 86400,
    this.team = 'All Teams',
    DateTime? loggedInAt,
  }) : loggedInAt = loggedInAt ?? DateTime.now();

  String get name => fullName.trim().isNotEmpty ? fullName : username;
  String get role => roles.isNotEmpty ? roles.first : 'ROLE_SUPPORT_MEMBER';
  String get token => accessToken;

  bool get isAdmin => roles.contains('ROLE_ADMIN');
  bool get isManager => isAdmin || roles.contains('ROLE_SUPPORT_MANAGER');
  bool get isTech => roles.contains('ROLE_TECHNICAL_SUPPORT_MEMBER');
  bool get isSupportMember => roles.contains('ROLE_SUPPORT_MEMBER');

  String get displayRole {
    if (isAdmin) return 'Admin';
    if (roles.contains('ROLE_SUPPORT_MANAGER')) return 'Support Manager';
    if (isTech) return 'Tech Support';
    if (isSupportMember) return 'Support Agent';
    return role.replaceAll('ROLE_', '').replaceAll('_', ' ');
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is Set) return val.map((e) => e.toString()).toList();
      return [];
    }

    final rawId = json['userId'] ?? json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '1') ?? 1;

    return UserSession(
      userId: parsedId,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      roles: parseList(json['roles']),
      permissions: parseList(json['permissions']),
      accessToken: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn'] is int
          ? json['expiresIn']
          : int.tryParse(json['expiresIn']?.toString() ?? '86400') ?? 86400,
      team: json['team']?.toString() ?? 'Support Team',
      loggedInAt: json['loggedInAt'] != null
          ? DateTime.tryParse(json['loggedInAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roles': roles,
      'permissions': permissions,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'team': team,
      'loggedInAt': loggedInAt.toIso8601String(),
    };
  }

  UserSession copyWith({
    int? userId,
    String? username,
    String? email,
    String? fullName,
    List<String>? roles,
    List<String>? permissions,
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    String? team,
    DateTime? loggedInAt,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      team: team ?? this.team,
      loggedInAt: loggedInAt ?? this.loggedInAt,
    );
  }
}
