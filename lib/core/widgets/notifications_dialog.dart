import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final notifications = notificationProvider.notifications;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (notificationProvider.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount} new',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: notifications.isEmpty
                      ? null
                      : () => notificationProvider.markAllAsRead(),
                  child: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 40, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'No notifications yet',
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => Divider(height: 12, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _buildNotificationTile(context, notif, notificationProvider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    AppNotification notif,
    NotificationProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppColors.primary;

    if (notif.type.contains('DELEGAT')) {
      iconData = Icons.alt_route_rounded;
      iconColor = AppColors.accent;
    } else if (notif.type.contains('ASSIGN')) {
      iconData = Icons.person_add_alt_1_rounded;
      iconColor = AppColors.primary;
    } else if (notif.type.contains('SLA')) {
      iconData = Icons.warning_rounded;
      iconColor = AppColors.slaBreached;
    } else if (notif.type.contains('RESOLVE') || notif.type.contains('COMPLET')) {
      iconData = Icons.check_circle_rounded;
      iconColor = AppColors.slaOk;
    }

    return InkWell(
      onTap: () {
        if (!notif.read) {
          provider.markAsRead(notif.id);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notif.read ? Colors.transparent : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: notif.read ? FontWeight.w500 : FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        DateFormatter.timeAgo(notif.createdAt),
                        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
