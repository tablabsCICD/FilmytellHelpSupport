class TeamMember {
  final String id;
  final int userIdInt;
  final String name;
  final String email;
  final String role; // Admin, Support Lead, Support Member, Technical Support Member
  final String team; // Support Team, Technical Support Team
  final List<String> expertise;
  final bool isAvailable;
  final int activeTicketsCount;
  final int activeDelegatedTasksCount;
  final double workloadPercentage; // 0 to 100

  TeamMember({
    required this.id,
    int? userIdInt,
    required this.name,
    required this.email,
    required this.role,
    required this.team,
    required this.expertise,
    this.isAvailable = true,
    this.activeTicketsCount = 0,
    this.activeDelegatedTasksCount = 0,
    this.workloadPercentage = 0.0,
  }) : userIdInt = userIdInt ?? (int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1);

  TeamMember copyWith({
    String? id,
    int? userIdInt,
    String? name,
    String? email,
    String? role,
    String? team,
    List<String>? expertise,
    bool? isAvailable,
    int? activeTicketsCount,
    int? activeDelegatedTasksCount,
    double? workloadPercentage,
  }) {
    return TeamMember(
      id: id ?? this.id,
      userIdInt: userIdInt ?? this.userIdInt,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      team: team ?? this.team,
      expertise: expertise ?? this.expertise,
      isAvailable: isAvailable ?? this.isAvailable,
      activeTicketsCount: activeTicketsCount ?? this.activeTicketsCount,
      activeDelegatedTasksCount: activeDelegatedTasksCount ?? this.activeDelegatedTasksCount,
      workloadPercentage: workloadPercentage ?? this.workloadPercentage,
    );
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final rawId = json['userId'] ?? json['id'];
    final parsedUserId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
    final fullName = json['fullName']?.toString() ?? json['name']?.toString() ?? json['username']?.toString() ?? '';

    // Determine role from backend roles or roleInTeam
    String roleStr = json['roleInTeam']?.toString() ?? json['role']?.toString() ?? 'Support Member';
    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final roleList = (json['roles'] as List).map((e) => e.toString()).toList();
      if (roleList.contains('ROLE_ADMIN')) {
        roleStr = 'Admin';
      } else if (roleList.contains('ROLE_SUPPORT_MANAGER')) {
        roleStr = 'Support Lead';
      } else if (roleList.contains('ROLE_TECHNICAL_SUPPORT_MEMBER')) {
        roleStr = 'Technical Support Member';
      } else {
        roleStr = 'Support Member';
      }
    }

    // Determine team from backend teams set or string
    String teamStr = json['team']?.toString() ?? '';
    if (teamStr.isEmpty && json['teams'] is List && (json['teams'] as List).isNotEmpty) {
      teamStr = (json['teams'] as List).first.toString();
    }
    if (teamStr.isEmpty) {
      teamStr = roleStr.contains('Tech') ? 'Technical Support Team' : 'Support Team';
    }

    // Active status
    final active = json['active'] is bool
        ? json['active'] as bool
        : (json['isAvailable'] != false);

    return TeamMember(
      id: parsedUserId > 0 ? parsedUserId.toString() : (json['id']?.toString() ?? '1'),
      userIdInt: parsedUserId,
      name: fullName,
      email: json['email']?.toString() ?? '',
      role: roleStr,
      team: teamStr,
      expertise: (json['expertise'] as List?)?.map((e) => e.toString()).toList() ??
          (roleStr.contains('Tech') ? ['Playback', 'DRM', 'Streaming'] : ['General Support', 'Billing']),
      isAvailable: active,
      activeTicketsCount: json['activeTicketsCount'] is int
          ? json['activeTicketsCount']
          : int.tryParse(json['activeTicketsCount']?.toString() ?? '0') ?? 0,
      activeDelegatedTasksCount: json['activeDelegatedTasksCount'] is int
          ? json['activeDelegatedTasksCount']
          : int.tryParse(json['activeDelegatedTasksCount']?.toString() ?? '0') ?? 0,
      workloadPercentage: json['workloadPercentage'] is num
          ? (json['workloadPercentage'] as num).toDouble()
          : double.tryParse(json['workloadPercentage']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userIdInt,
      'name': name,
      'fullName': name,
      'email': email,
      'role': role,
      'team': team,
      'expertise': expertise,
      'isAvailable': isAvailable,
      'active': isAvailable,
      'activeTicketsCount': activeTicketsCount,
      'activeDelegatedTasksCount': activeDelegatedTasksCount,
      'workloadPercentage': workloadPercentage,
    };
  }
}
