import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/team_member_model.dart';
import '../../../providers/team_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  void _showAddEditMemberDialog({TeamMember? member}) {
    final nameController = TextEditingController(text: member?.name ?? '');
    final emailController = TextEditingController(text: member?.email ?? '');
    final expertiseController = TextEditingController(text: member?.expertise.join(', ') ?? '');
    String selectedTeam = member?.team ?? AppConstants.teamSupport;
    if (!AppConstants.allTeams.contains(selectedTeam)) {
      selectedTeam = AppConstants.teamSupport;
    }
    String selectedRole = member?.role ?? 'Support Member';
    String? errorMessage;
    bool isSubmitting = false;

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            title: Row(
              children: [
                Icon(
                  member == null ? Icons.person_add_alt_1_rounded : Icons.edit_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  member == null ? 'Add Team Member' : 'Edit Team Member',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.priorityUrgent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppColors.priorityUrgent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(fontSize: 12, color: AppColors.priorityUrgent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'e.g. John Doe'),
                  ),
                  const SizedBox(height: 12),
                  Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'e.g. john.doe@filmytell.com'),
                  ),
                  const SizedBox(height: 12),
                  Text('Team', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTeam,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    items: AppConstants.allTeams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedTeam = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Role & Permissions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'Admin', child: Text('Admin (Full Control)')),
                      DropdownMenuItem(value: 'Support Lead', child: Text('Support Lead')),
                      DropdownMenuItem(value: 'Support Member', child: Text('Support Member')),
                      DropdownMenuItem(value: 'Technical Support Member', child: Text('Technical Support Member')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Expertise Tags (comma separated)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: expertiseController,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'e.g. Playback, DRM, Billing, Subtitles'),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        if (name.isEmpty) {
                          setState(() => errorMessage = 'Please enter a valid full name.');
                          return;
                        }
                        if (email.isEmpty || !email.contains('@')) {
                          setState(() => errorMessage = 'Please enter a valid email address.');
                          return;
                        }

                        setState(() {
                          errorMessage = null;
                          isSubmitting = true;
                        });

                        final expertiseList = expertiseController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          if (member == null) {
                            final newMem = TeamMember(
                              id: 'tm_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              email: email,
                              role: selectedRole,
                              team: selectedTeam,
                              expertise: expertiseList.isNotEmpty
                                  ? expertiseList
                                  : (selectedTeam == AppConstants.teamTechnical
                                      ? ['Playback', 'DRM']
                                      : ['General Support', 'Billing']),
                              workloadPercentage: 10.0,
                            );
                            await teamProvider.addMember(newMem);
                          } else {
                            final updated = member.copyWith(
                              name: name,
                              email: email,
                              role: selectedRole,
                              team: selectedTeam,
                              expertise: expertiseList,
                            );
                            await teamProvider.updateMember(updated);
                          }

                          if (ctx.mounted) Navigator.pop(ctx);

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(member == null ? 'Team member added successfully.' : 'Team member updated successfully.'),
                              backgroundColor: AppColors.slaOk,
                            ),
                          );
                        } catch (e) {
                          if (ctx.mounted) {
                            String displayErr = e.toString();
                            if (displayErr.startsWith('Exception: ')) {
                              displayErr = displayErr.substring(11);
                            }
                            setState(() {
                              isSubmitting = false;
                              errorMessage = displayErr;
                            });
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Member'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support & Technical Team Rosters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage staff availability, specializations, roles, and load balancing across desks',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: teamProvider.isLoading
                          ? null
                          : () => teamProvider.loadMembers(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh Roster'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditMemberDialog(),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text('Add Team Member'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Team Filter Tabs
            Wrap(
              spacing: 8,
              children: ['All', ...AppConstants.allTeams].map((team) {
                final isSelected = (teamProvider.selectedTeamFilter == null && team == 'All') || teamProvider.selectedTeamFilter == team;
                return ChoiceChip(
                  label: Text(team),
                  selected: isSelected,
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (_) => teamProvider.setTeamFilter(team == 'All' ? null : team),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Members Grid
            Expanded(
              child: teamProvider.filteredMembers.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No team members found',
                      message: 'No active staff or agents match the selected team filter.',
                      icon: Icons.groups_outlined,
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 480,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: teamProvider.filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = teamProvider.filteredMembers[index];

                  Color barColor = AppColors.slaOk;
                  if (member.workloadPercentage > 75) {
                    barColor = AppColors.priorityUrgent;
                  } else if (member.workloadPercentage > 50) {
                    barColor = AppColors.priorityMedium;
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: Avatar + Name + Edit/Toggle
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: (member.team == AppConstants.teamTechnical ? AppColors.teamTech : AppColors.teamSupport).withValues(alpha: 0.2),
                              child: Text(
                                member.name.substring(0, member.name.length >= 2 ? 2 : 1).toUpperCase(),
                                style: TextStyle(
                                  color: member.team == AppConstants.teamTechnical ? AppColors.teamTech : AppColors.teamSupport,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        member.name,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: member.isAvailable ? AppColors.slaOk.withValues(alpha: 0.15) : AppColors.priorityUrgent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          member.isAvailable ? 'AVAILABLE' : 'OFFLINE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: member.isAvailable ? AppColors.slaOk : AppColors.priorityUrgent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${member.role} • ${member.team}',
                                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                              onPressed: () => _showAddEditMemberDialog(member: member),
                            ),
                          ],
                        ),

                        // Expertise Pills
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: member.expertise.take(3).map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Text(e, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                            );
                          }).toList(),
                        ),

                        // Workload bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Workload: ${member.activeTicketsCount} primary • ${member.activeDelegatedTasksCount} delegated',
                                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  '${member.workloadPercentage.toInt()}% Capacity',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (member.workloadPercentage / 100).clamp(0.05, 1.0),
                                backgroundColor: colorScheme.outlineVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),

                        // Availability Toggle Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              member.email,
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                            ),
                            Transform.scale(
                              scale: 0.75,
                              child: Switch(
                                value: member.isAvailable,
                                activeThumbColor: AppColors.slaOk,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (_) => teamProvider.toggleAvailability(member.id),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
