import 'package:flutter/material.dart';
import '../core/widgets/app_sidebar.dart';
import '../core/widgets/responsive_layout.dart';
import '../models/support_ticket_model.dart';
import 'dashboard/screens/dashboard_screen.dart';
import 'tickets/screens/all_tickets_screen.dart';
import 'kanban/screens/kanban_screen.dart';
import 'my_tasks/screens/my_tasks_screen.dart';
import 'team/screens/team_management_screen.dart';
import 'reports/screens/reports_screen.dart';
import 'knowledge_base/screens/knowledge_base_screen.dart';
import 'ai_support/screens/ai_settings_screen.dart';
import 'settings/screens/settings_screen.dart';
import 'ticket_details/screens/ticket_details_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  SupportTicket? _activeTicketDetails;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _activeTicketDetails = null;
    });
  }

  void _openTicketDetails(SupportTicket ticket) {
    setState(() {
      _activeTicketDetails = ticket;
    });
  }

  void _closeTicketDetails() {
    setState(() {
      _activeTicketDetails = null;
    });
  }

  Widget _buildBody() {
    if (_activeTicketDetails != null) {
      return TicketDetailsScreen(
        ticket: _activeTicketDetails!,
        onBack: _closeTicketDetails,
      );
    }

    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigateTab: _onDestinationSelected,
          onSelectTicket: _openTicketDetails,
        );
      case 1:
        return AllTicketsScreen(onSelectTicket: _openTicketDetails);
      case 2:
        return KanbanScreen(onSelectTicket: _openTicketDetails);
      case 3:
        return MyTasksScreen(onSelectTicket: _openTicketDetails);
      case 4:
        return const TeamManagementScreen();
      case 5:
        return const ReportsScreen();
      case 6:
        return const KnowledgeBaseScreen();
      case 7:
        return const AiSettingsScreen();
      case 8:
        return const SettingsScreen();
      default:
        return DashboardScreen(
          onNavigateTab: _onDestinationSelected,
          onSelectTicket: _openTicketDetails,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AppSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      );
    }

    // Mobile / Tablet Drawer Layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmytell Support Portal'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) {
            _onDestinationSelected(idx);
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }
}
