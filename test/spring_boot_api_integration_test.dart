import 'package:flutter_test/flutter_test.dart';
import 'package:filmytell_help_support/models/support_ticket_model.dart';
import 'package:filmytell_help_support/models/delegation_model.dart';
import 'package:filmytell_help_support/models/notification_model.dart';
import 'package:filmytell_help_support/services/kanban_api_service.dart';
import 'package:filmytell_help_support/services/dashboard_api_service.dart';
import 'package:filmytell_help_support/models/user_session.dart';
import 'package:filmytell_help_support/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Spring Boot DTO Parsing Tests', () {
    test('Should parse Spring Boot TicketResponse with all new fields', () {
      final json = {
        'id': 42,
        'ticketNumber': 'FT-00042',
        'subject': 'ExoPlayer video freeze on 4K stream',
        'description': 'Customer reported playback stall at 23:45 on FireTV 4K stick.',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'category': 'Playback & Streaming',
        'sourcePortal': 'FILMYTELL',
        'teamId': 2,
        'teamName': 'Technical Support Team',
        'ownerId': 1,
        'ownerName': 'Rahul Manager',
        'assigneeId': 3,
        'assigneeName': 'Charlie Tech',
        'delegationLevel': 1,
        'activeTaskCount': 1,
        'slaDueAt': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'slaBreached': false,
        'aiResolved': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, equals(42));
      expect(ticket.ticketId, equals('42'));
      expect(ticket.ticketNumber, equals('FT-00042'));
      expect(ticket.status, equals('IN_PROGRESS'));
      expect(ticket.priority, equals('HIGH'));
      expect(ticket.ticketOwner, equals('Rahul Manager'));
      expect(ticket.currentAssignee, equals('Charlie Tech'));
      expect(ticket.delegationLevel, equals(1));
      expect(ticket.team, equals('Technical Support Team'));
      expect(ticket.slaBreached, isFalse);
    });

    test('Should parse TicketTaskResponse into DelegationNode', () {
      final taskJson = {
        'id': 101,
        'ticketId': 42,
        'parentTaskId': null,
        'assignedFromUserId': 1,
        'assignedFromUserName': 'Rahul Manager',
        'assignedToUserId': 3,
        'assignedToUserName': 'Charlie Tech',
        'delegationLevel': 1,
        'reason': 'TECHNICAL_DEPENDENCY',
        'instructions': 'Inspect player telemetry logs and CDN routing headers.',
        'status': 'IN_PROGRESS',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final node = DelegationNode.fromJson(taskJson);

      expect(node.taskId, equals(101));
      expect(node.ticketId, equals('42'));
      expect(node.assignedFromUserName, equals('Rahul Manager'));
      expect(node.assignedToUserName, equals('Charlie Tech'));
      expect(node.fromUserName, equals('Rahul Manager'));
      expect(node.toUserName, equals('Charlie Tech'));
      expect(node.delegationLevel, equals(1));
      expect(node.status, equals('IN_PROGRESS'));
    });

    test('Should parse KanbanBoardData from /api/v1/kanban payload', () {
      final boardJson = {
        'columns': [
          {
            'status': 'NEW',
            'title': 'New',
            'count': 2,
            'tickets': [
              {
                'id': 1,
                'ticketNumber': 'FT-00001',
                'subject': 'Login issue',
                'description': 'Cannot login',
                'status': 'NEW',
                'priority': 'MEDIUM',
                'category': 'Account',
                'sourcePortal': 'FILMYTELL',
                'createdAt': DateTime.now().toIso8601String(),
              },
            ],
          },
          {
            'status': 'IN_PROGRESS',
            'title': 'In Progress',
            'count': 1,
            'tickets': [],
          },
        ],
        'totalTickets': 3,
      };

      final board = KanbanBoardData.fromJson(boardJson);

      expect(board.totalTickets, equals(3));
      expect(board.columns.length, equals(2));
      expect(board.columns.first.status, equals('NEW'));
      expect(board.columns.first.tickets.length, equals(1));
      expect(board.columns.first.tickets.first.ticketNumber, equals('FT-00001'));
    });

    test('Should parse DashboardSummaryData from /api/v1/dashboard/summary', () {
      final summaryJson = {
        'totalTickets': 120,
        'openTickets': 45,
        'urgentTickets': 8,
        'highPriorityTickets': 15,
        'pendingUserTickets': 5,
        'inProgressTickets': 22,
        'resolvedTickets': 60,
        'closedTickets': 15,
        'slaBreachedTickets': 3,
        'aiResolvedTickets': 24,
        'aiEscalatedTickets': 6,
        'averageResolutionTimeMinutes': 185.5,
        'averageFirstResponseTimeMinutes': 12.3,
        'totalDelegatedTasks': 34,
        'averageDelegationDepth': 1.45,
        'ticketsByStatus': {'NEW': 10, 'IN_PROGRESS': 22, 'RESOLVED': 60},
        'ticketsByPriority': {'URGENT': 8, 'HIGH': 15, 'MEDIUM': 45, 'LOW': 52},
        'ticketsBySourcePortal': {'FILMYTELL': 90, 'PARTNER_PORTAL': 30},
      };

      final summary = DashboardSummaryData.fromJson(summaryJson);

      expect(summary.totalTickets, equals(120));
      expect(summary.openTickets, equals(45));
      expect(summary.aiResolvedTickets, equals(24));
      expect(summary.averageResolutionTimeMinutes, closeTo(185.5, 0.01));
      expect(summary.ticketsByStatus['IN_PROGRESS'], equals(22));
    });

    test('Should parse NotificationResponse into AppNotification', () {
      final notifJson = {
        'id': 501,
        'recipientUserId': 3,
        'ticketId': 42,
        'type': 'TASK_DELEGATED',
        'channel': 'IN_APP',
        'title': 'Task Delegated to You',
        'message': 'Rahul Manager delegated ticket FT-00042 to you',
        'read': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final notif = AppNotification.fromJson(notifJson);

      expect(notif.id, equals(501));
      expect(notif.ticketId, equals(42));
      expect(notif.type, equals('TASK_DELEGATED'));
      expect(notif.read, isFalse);
    });

    test('Should parse AuthResponse into UserSession with roles', () {
      final authJson = {
        'accessToken': 'jwt.token.here',
        'refreshToken': 'refresh.token.here',
        'tokenType': 'Bearer',
        'expiresIn': 86400,
        'userId': 1,
        'username': 'admin',
        'email': 'admin@filmytell.com',
        'fullName': 'System Administrator',
        'roles': ['ROLE_ADMIN'],
        'permissions': ['TICKET_READ', 'TICKET_WRITE', 'TASK_OVERRIDE'],
      };

      final session = UserSession.fromJson(authJson);

      expect(session.userId, equals(1));
      expect(session.email, equals('admin@filmytell.com'));
      expect(session.name, equals('System Administrator'));
      expect(session.isAdmin, isTrue);
      expect(session.isTech, isFalse);
    });

    test('Should allow local admin user login from local db when backend is unreachable', () async {
      SharedPreferences.setMockInitialValues({});
      final authRepo = AuthRepository();
      final session = await authRepo.login(
        email: 'admin@filmytell.com',
        password: 'Password@123',
      );

      expect(session.userId, equals(1));
      expect(session.username, equals('admin'));
      expect(session.email, equals('admin@filmytell.com'));
      expect(session.isAdmin, isTrue);
      expect(session.roles, contains('ROLE_ADMIN'));
    });
  });
}
