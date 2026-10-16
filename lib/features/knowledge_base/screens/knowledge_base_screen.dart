import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../models/knowledge_base_article.dart';
import '../../../providers/knowledge_base_provider.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  void _showArticleViewerDialog(KnowledgeBaseArticle article) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                article.category.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 8),
            Text(article.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                article.content,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface, height: 1.5),
              ),
              Divider(height: 24, color: colorScheme.outlineVariant),
              Wrap(
                spacing: 6,
                children: article.tags.map((t) {
                  return Chip(
                    label: Text('#$t', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Article')),
        ],
      ),
    );
  }

  void _showAddArticleDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Technical');
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    final kbProvider = Provider.of<KnowledgeBaseProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant)),
        title: Text('Add Knowledge Base Article', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              TextField(controller: titleController, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 12),
              Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              TextField(controller: categoryController, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 12),
              Text('Article Content / Troubleshooting Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              TextField(controller: contentController, maxLines: 4, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 12),
              Text('Tags (comma separated)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              TextField(controller: tagsController, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              final article = KnowledgeBaseArticle(
                id: 'kb_${DateTime.now().millisecondsSinceEpoch}',
                title: titleController.text.trim(),
                category: categoryController.text.trim(),
                content: contentController.text.trim(),
                tags: tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                updatedAt: DateTime.now(),
              );
              await kbProvider.addArticle(article);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Article'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kbProvider = Provider.of<KnowledgeBaseProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final categories = ['All', 'Technical', 'Billing', 'General'];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Add
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Knowledge Base & Resolution SOPs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Standard operating procedures, FAQs, troubleshooting runbooks & AI reference documents',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddArticleDialog,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Article'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Categories
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search KB articles by keyword, symptom or tag...',
                      prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                    ),
                    onChanged: (val) => kbProvider.setSearchQuery(val),
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  children: categories.map((cat) {
                    final isSelected = (kbProvider.selectedCategory == null && cat == 'All') || kbProvider.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: colorScheme.primaryContainer,
                      backgroundColor: colorScheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (_) => kbProvider.setSelectedCategory(cat == 'All' ? null : cat),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Articles Grid
            Expanded(
              child: kbProvider.filteredArticles.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No knowledge base articles found',
                      message: 'Try a different search query or add a new troubleshooting article.',
                      icon: Icons.menu_book_outlined,
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 460,
                        mainAxisExtent: 180,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: kbProvider.filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = kbProvider.filteredArticles[index];
                        return Card(
                          child: InkWell(
                            onTap: () => _showArticleViewerDialog(article),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              article.category.toUpperCase(),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.thumb_up_alt_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                                              const SizedBox(width: 3),
                                              Text('${article.helpfulCount}', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        article.title,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Updated: ${DateFormatter.formatDateOnly(article.updatedAt)}',
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                      ),
                                      const Text('Read Guide →', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
