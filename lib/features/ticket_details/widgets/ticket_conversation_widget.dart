import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/support_ticket_model.dart';
import '../../../models/ticket_message_model.dart';
import '../../../providers/ticket_provider.dart';
import '../../../providers/auth_provider.dart';

class TicketConversationWidget extends StatefulWidget {
  final SupportTicket ticket;

  const TicketConversationWidget({super.key, required this.ticket});

  @override
  State<TicketConversationWidget> createState() => _TicketConversationWidgetState();
}

class _TicketConversationWidgetState extends State<TicketConversationWidget> {
  final _textController = TextEditingController();
  bool _isInternalNote = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentSession?.name ?? 'Admin User';
    final messenger = ScaffoldMessenger.of(context);

    final targetId = widget.ticket.id > 0 ? widget.ticket.id.toString() : widget.ticket.ticketId;

    final message = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: targetId,
      senderName: currentUser,
      senderRole: _isInternalNote ? 'Staff Note' : 'Support Staff',
      content: text,
      type: _isInternalNote ? MessageType.internalNote : MessageType.supportReply,
      timestamp: DateTime.now(),
    );

    try {
      await ticketProvider.addMessage(targetId, message);
      _textController.clear();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(_isInternalNote ? 'Internal note added successfully.' : 'Customer reply sent successfully.'),
            backgroundColor: AppColors.slaOk,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.slaBreached,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.forum_outlined, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Communication & Internal Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendPill('User', AppColors.statusNew),
                  const SizedBox(width: 6),
                  _buildLegendPill('Support', AppColors.accent),
                  const SizedBox(width: 6),
                  _buildLegendPill('Internal Note', Colors.amber.shade700),
                  const SizedBox(width: 6),
                  _buildLegendPill('AI Bot', AppColors.statusAiAnalysis),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Message Feed
          if (widget.ticket.messages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No messages or notes yet. Start the conversation below.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ticket.messages.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = widget.ticket.messages[index];
                return _buildMessageBubble(context, msg);
              },
            ),
          const SizedBox(height: 20),

          // Compose Input Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isInternalNote ? Colors.amber.withValues(alpha: 0.08) : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isInternalNote ? Colors.amber.withValues(alpha: 0.4) : colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: _isInternalNote,
                          activeThumbColor: Colors.amber.shade700,
                          onChanged: (val) {
                            setState(() => _isInternalNote = val);
                          },
                        ),
                        Text(
                          _isInternalNote ? 'Internal Staff Note (Hidden from user)' : 'Public Customer Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isInternalNote ? Colors.amber.shade700 : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: _isInternalNote
                        ? 'Type private note visible only to support team...'
                        : 'Write message to customer...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: Text(_isInternalNote ? 'Add Internal Note' : 'Send Customer Reply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isInternalNote ? Colors.amber.shade800 : AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildMessageBubble(BuildContext context, TicketMessage msg) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bubbleBg;
    Color borderColor;
    Color tagColor;
    String tagLabel;
    IconData icon;

    switch (msg.type) {
      case MessageType.internalNote:
        bubbleBg = Colors.amber.withValues(alpha: 0.08);
        borderColor = Colors.amber.withValues(alpha: 0.3);
        tagColor = Colors.amber.shade700;
        tagLabel = 'INTERNAL NOTE';
        icon = Icons.lock_outline_rounded;
        break;
      case MessageType.aiResponse:
        bubbleBg = AppColors.statusAiAnalysis.withValues(alpha: 0.08);
        borderColor = AppColors.statusAiAnalysis.withValues(alpha: 0.3);
        tagColor = AppColors.statusAiAnalysis;
        tagLabel = 'AI BOT';
        icon = Icons.smart_toy_outlined;
        break;
      case MessageType.userMessage:
        bubbleBg = AppColors.statusNew.withValues(alpha: 0.08);
        borderColor = AppColors.statusNew.withValues(alpha: 0.3);
        tagColor = AppColors.statusNew;
        tagLabel = 'USER';
        icon = Icons.person_outline_rounded;
        break;
      case MessageType.supportReply:
        bubbleBg = AppColors.accent.withValues(alpha: 0.08);
        borderColor = AppColors.accent.withValues(alpha: 0.3);
        tagColor = AppColors.accent;
        tagLabel = 'SUPPORT AGENT';
        icon = Icons.support_agent_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: tagColor),
                  const SizedBox(width: 6),
                  Text(
                    msg.senderName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagLabel,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor),
                    ),
                  ),
                ],
              ),
              Text(
                DateFormatter.formatDateTime(msg.timestamp),
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg.content,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface, height: 1.35),
          ),
        ],
      ),
    );
  }
}
