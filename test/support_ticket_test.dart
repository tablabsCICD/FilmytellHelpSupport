import 'package:flutter_test/flutter_test.dart';
import 'package:filmytell_help_support/core/constants/app_constants.dart';
import 'package:filmytell_help_support/core/utils/sla_calculator.dart';
import 'package:filmytell_help_support/models/rating_review_model.dart';
import 'package:filmytell_help_support/models/support_ticket_model.dart';
import 'package:filmytell_help_support/models/delegation_model.dart';

void main() {
  group('Rating & Review API Mapping Tests', () {
    test('Should map RatingReviewItem to SupportTicket with FT number format', () {
      final review = RatingReviewItem(
        reviewId: 42,
        userId: 101,
        contentId: 5,
        rating: 1,
        title: 'Video freezes constantly',
        comment: 'Playback stops at 12:04 on Android TV app.',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final ticket = SupportTicket.fromRatingReview(review, 0);

      expect(ticket.ticketNumber, equals('FT-0001'));
      expect(ticket.userId, equals(101));
      expect(ticket.contentId, equals(5));
      expect(ticket.rating, equals(1));
      expect(ticket.priority, equals(AppConstants.priorityHigh)); // 1 star maps to high priority
      expect(ticket.team, equals(AppConstants.teamTechnical));
      expect(ticket.status, equals(AppConstants.statusNew));
      expect(ticket.messages.length, equals(1));
      expect(ticket.history.length, equals(1));
    });

    test('Should handle 5-star positive review correctly', () {
      final review = RatingReviewItem(
        reviewId: 43,
        userId: 202,
        contentId: 9,
        rating: 5,
        title: 'Loved the movie',
        comment: 'Great quality stream!',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final ticket = SupportTicket.fromRatingReview(review, 1);

      expect(ticket.ticketNumber, equals('FT-0002'));
      expect(ticket.priority, equals(AppConstants.priorityLow));
      expect(ticket.team, equals(AppConstants.teamSupport));
    });
  });

  group('SLA Calculator Tests', () {
    test('Should calculate correct SLA hours per priority', () {
      expect(SlaCalculator.getSlaHours(AppConstants.priorityUrgent), equals(2));
      expect(SlaCalculator.getSlaHours(AppConstants.priorityHigh), equals(4));
      expect(SlaCalculator.getSlaHours(AppConstants.priorityMedium), equals(8));
      expect(SlaCalculator.getSlaHours(AppConstants.priorityLow), equals(24));
    });

    test('Should detect breached SLA when time elapsed exceeds target', () {
      final createdLongAgo = DateTime.now().subtract(const Duration(hours: 5));
      final slaInfo = SlaCalculator.getSlaInfo(
        createdLongAgo,
        AppConstants.priorityUrgent, // 2 hours SLA
        AppConstants.statusInProgress,
      );

      expect(slaInfo.isBreached, isTrue);
      expect(slaInfo.status, equals(SlaStatus.breached));
    });

    test('Should return OK SLA when within target window', () {
      final justCreated = DateTime.now().subtract(const Duration(minutes: 15));
      final slaInfo = SlaCalculator.getSlaInfo(
        justCreated,
        AppConstants.priorityLow, // 24 hours SLA
        AppConstants.statusInProgress,
      );

      expect(slaInfo.isBreached, isFalse);
      expect(slaInfo.status, equals(SlaStatus.ok));
    });
  });

  group('Multi-level Delegation Tests', () {
    test('Should preserve ticket owner while advancing delegation level and assignee', () {
      final ticket = SupportTicket(
        ticketId: 't1',
        ticketNumber: 'FT-0001',
        userId: 1,
        contentId: 2,
        rating: 3,
        title: 'Issue',
        description: 'Desc',
        createdAt: DateTime.now(),
        status: AppConstants.statusAssigned,
        priority: AppConstants.priorityHigh,
        team: AppConstants.teamTechnical,
        ticketOwner: 'Rahul',
        currentAssignee: 'Rahul',
        category: 'Playback',
        source: AppConstants.sourceFilmytell,
      );

      // Level 1: Rahul delegates to Sneha
      final del1 = DelegationNode(
        id: 'd1',
        ticketId: 't1',
        ticketOwnerName: ticket.ticketOwner,
        fromUserName: 'Rahul',
        toUserName: 'Sneha',
        teamName: AppConstants.teamTechnical,
        delegationLevel: 1,
        reason: 'Expertise',
        instructions: 'Investigate DRM module',
        delegatedAt: DateTime.now(),
        status: AppConstants.delegationInProgress,
      );

      final ticketL1 = ticket.copyWith(
        currentAssignee: 'Sneha',
        delegatedFrom: 'Rahul',
        delegationLevel: 1,
        delegations: [del1],
      );

      expect(ticketL1.ticketOwner, equals('Rahul')); // Owner preserved!
      expect(ticketL1.currentAssignee, equals('Sneha'));
      expect(ticketL1.delegationLevel, equals(1));

      // Level 2: Sneha delegates to Akshay
      final del2 = DelegationNode(
        id: 'd2',
        ticketId: 't1',
        ticketOwnerName: ticket.ticketOwner,
        fromUserName: 'Sneha',
        toUserName: 'Akshay',
        teamName: AppConstants.teamTechnical,
        delegationLevel: 2,
        parentDelegationId: 'd1',
        reason: 'Technical Dependency',
        instructions: 'Check server logs',
        delegatedAt: DateTime.now(),
        status: AppConstants.delegationPending,
      );

      final ticketL2 = ticketL1.copyWith(
        currentAssignee: 'Akshay',
        delegatedFrom: 'Sneha',
        delegationLevel: 2,
        delegations: [del2, del1],
      );

      expect(ticketL2.ticketOwner, equals('Rahul')); // Still Rahul!
      expect(ticketL2.currentAssignee, equals('Akshay'));
      expect(ticketL2.delegationLevel, equals(2));
      expect(ticketL2.delegations.length, equals(2));
    });
  });
}
