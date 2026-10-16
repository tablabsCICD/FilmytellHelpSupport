import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/support_ticket_model.dart';
import '../../../models/ai_analysis_model.dart';
import '../../../providers/ticket_provider.dart';

class AiAnalysisDialog extends StatefulWidget {
  final SupportTicket ticket;

  const AiAnalysisDialog({super.key, required this.ticket});

  @override
  State<AiAnalysisDialog> createState() => _AiAnalysisDialogState();
}

class _AiAnalysisDialogState extends State<AiAnalysisDialog> {
  bool _isAnalyzing = false;
  AiAnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _result = widget.ticket.aiAnalysis;
    if (_result == null) {
      _runAiAnalysis();
    }
  }

  Future<void> _runAiAnalysis() async {
    setState(() => _isAnalyzing = true);
    // Simulated deep semantic NLP processing
    await Future.delayed(const Duration(milliseconds: 900));

    final text = '${widget.ticket.title} ${widget.ticket.description}'.toLowerCase();

    String category = 'General Support';
    String subCategory = 'General Query';
    String intent = 'Customer assistance request';
    String priority = AppConstants.priorityMedium;
    String team = AppConstants.teamSupport;
    double confidence = 0.88;
    String solution = 'Guide user through standard helpdesk articles or account preferences.';
    bool canAutoResolve = false;

    if (text.contains('buffer') || text.contains('stutter') || text.contains('playback') || text.contains('video') || text.contains('4k')) {
      category = 'Playback';
      subCategory = 'Video Buffering / Codec Stutter';
      intent = 'Video stream buffering on device';
      priority = AppConstants.priorityHigh;
      team = AppConstants.teamTechnical;
      confidence = 0.94;
      solution = 'Verify HLS manifest chunk latency. Advise user to test connection speed >= 25Mbps or switch to Auto bitrate.';
      canAutoResolve = true;
    } else if (text.contains('payment') || text.contains('upi') || text.contains('refund') || text.contains('deduct') || text.contains('bill')) {
      category = 'Billing & Subscriptions';
      subCategory = 'Duplicate Transaction / Refund';
      intent = 'Payment debit verification';
      priority = AppConstants.priorityUrgent;
      team = AppConstants.teamSupport;
      confidence = 0.96;
      solution = 'Cross-verify UPI 12-digit UTR on gateway settlement ledger. If captured twice, execute instant refund webhook.';
      canAutoResolve = false;
    } else if (text.contains('audio') || text.contains('subtitle') || text.contains('sync') || text.contains('tamil') || text.contains('hindi')) {
      category = 'Audio & Subtitles';
      subCategory = 'Track Rendition Sync';
      intent = 'Subtitle / language track mismatch';
      priority = AppConstants.priorityMedium;
      team = AppConstants.teamTechnical;
      confidence = 0.92;
      solution = 'Check WebVTT timestamp alignment in packaging profile.';
      canAutoResolve = false;
    } else if (text.contains('download') || text.contains('offline')) {
      category = 'Feature Usage';
      subCategory = 'Offline Downloads';
      intent = 'How-to download guide';
      priority = AppConstants.priorityLow;
      team = AppConstants.teamSupport;
      confidence = 0.98;
      solution = 'Direct user to native app offline downloader button with 30-day offline validity explanation.';
      canAutoResolve = true;
    }

    final analysis = AiAnalysisResult(
      category: category,
      subCategory: subCategory,
      intent: intent,
      suggestedPriority: priority,
      suggestedTeam: team,
      confidence: confidence,
      suggestedSolution: solution,
      canAutoResolve: canAutoResolve,
    );

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _result = analysis;
      });
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      ticketProvider.setAiAnalysis(widget.ticket.ticketId, analysis);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusAiAnalysis.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.smart_toy_outlined, color: AppColors.statusAiAnalysis, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Intelligent Triage & Solution Analysis',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                        Text(
                          'Automated classification & intent analysis for ${widget.ticket.ticketNumber}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: colorScheme.outlineVariant),

              if (_isAnalyzing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppColors.statusAiAnalysis),
                        const SizedBox(height: 16),
                        Text('Analyzing ticket subject, description & sentiment...', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else if (_result != null) ...[
                // Confidence & Intent Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusAiAnalysis.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.statusAiAnalysis.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.statusAiAnalysis, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Detected Intent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusAiAnalysis)),
                                Text(
                                  '${(_result!.confidence * 100).toInt()}% Confidence',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusAiAnalysis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _result!.intent,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Analysis Details Table
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _buildAnalysisRow(context, 'Category', '${_result!.category} → ${_result!.subCategory}'),
                      Divider(height: 14, color: colorScheme.outlineVariant),
                      _buildAnalysisRow(context, 'Suggested Priority', _result!.suggestedPriority),
                      Divider(height: 14, color: colorScheme.outlineVariant),
                      _buildAnalysisRow(context, 'Suggested Team', _result!.suggestedTeam),
                      Divider(height: 14, color: colorScheme.outlineVariant),
                      _buildAnalysisRow(context, 'Auto-Resolution Safe', _result!.canAutoResolve ? 'Yes (Low Risk)' : 'No (Requires Human Action)'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Suggested Solution Box
                Text('AI Suggested Solution / Next Steps', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    _result!.suggestedSolution,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface, height: 1.35),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _runAiAnalysis(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Re-Analyze'),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Apply AI recommendation to ticket
                            await ticketProvider.updateTicketPriority(
                              widget.ticket.ticketId,
                              _result!.suggestedPriority,
                              'AI Engine',
                            );
                            if (_result!.canAutoResolve) {
                              await ticketProvider.updateTicketStatus(
                                widget.ticket.ticketId,
                                AppConstants.statusAiResolved,
                                'Filmytell AI Engine',
                                notes: 'AI Auto-Response dispatched to user.',
                              );
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('AI recommendations applied to ticket!'),
                                  backgroundColor: AppColors.statusAiAnalysis,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Apply AI Recommendations'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAiAnalysis),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      ],
    );
  }
}
