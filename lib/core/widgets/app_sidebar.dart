import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/notification_provider.dart';
import 'notifications_dialog.dart';

class NavItem {
  final String title;
  final IconData icon;
  final int index;
  final int? badgeCount;

  const NavItem({
    required this.title,
    required this.icon,
    required this.index,
    this.badgeCount,
  });
}

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final currentUser = authProvider.currentSession;
    final colorScheme = Theme.of(context).colorScheme;

    final navItems = [
      NavItem(title: 'Dashboard', icon: Icons.dashboard_outlined, index: 0),
      NavItem(title: 'All Tickets', icon: Icons.confirmation_number_outlined, index: 1, badgeCount: ticketProvider.allTickets.length),
      NavItem(title: 'Kanban Board', icon: Icons.view_kanban_outlined, index: 2),
      NavItem(title: 'My Tasks', icon: Icons.task_alt_outlined, index: 3, badgeCount: ticketProvider.allTickets.where((t) => t.currentAssignee == (currentUser?.name ?? 'Admin User') || t.delegatedFrom == (currentUser?.name ?? 'Admin User')).length),
      NavItem(title: 'Team Management', icon: Icons.people_outline_rounded, index: 4),
      NavItem(title: 'Reports & Analytics', icon: Icons.insights_outlined, index: 5),
      NavItem(title: 'Knowledge Base', icon: Icons.menu_book_outlined, index: 6),
      NavItem(title: 'AI Settings', icon: Icons.smart_toy_outlined, index: 7),
      NavItem(title: 'Settings', icon: Icons.settings_outlined, index: 8),
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant, width: 1)),
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FILMYTELL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Help & Support Desk',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notifProvider, _) {
                    final unread = notifProvider.unreadCount;
                    return IconButton(
                      tooltip: 'Notifications ($unread)',
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                          if (unread > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const NotificationsDialog(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),

          // User Profile Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    (currentUser?.name.isNotEmpty ?? false)
                        ? currentUser!.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                        : 'AU',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'Admin User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.slaOk, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentUser?.role ?? 'Admin',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  color: colorScheme.surface,
                  onSelected: (val) {
                    if (val == 'logout') {
                      authProvider.logout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 16, color: AppColors.priorityUrgent),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: AppColors.priorityUrgent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nav Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: navItems.length,
              separatorBuilder: (c, i) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedIndex == item.index;

                return InkWell(
                  onTap: () => onDestinationSelected(item.index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.40))
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 19,
                          color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (item.badgeCount != null && item.badgeCount! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? AppColors.primary : colorScheme.outlineVariant),
                            ),
                            child: Text(
                              item.badgeCount.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => authProvider.logout(),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Logout Session'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
