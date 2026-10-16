class KnowledgeBaseArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final List<String> tags;
  final int viewsCount;
  final int helpfulCount;
  final DateTime updatedAt;

  KnowledgeBaseArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.tags,
    this.viewsCount = 0,
    this.helpfulCount = 0,
    required this.updatedAt,
  });

  factory KnowledgeBaseArticle.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      content: json['content']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      viewsCount: json['viewsCount'] is int ? json['viewsCount'] : int.tryParse(json['viewsCount']?.toString() ?? '0') ?? 0,
      helpfulCount: json['helpfulCount'] is int ? json['helpfulCount'] : int.tryParse(json['helpfulCount']?.toString() ?? '0') ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'tags': tags,
      'viewsCount': viewsCount,
      'helpfulCount': helpfulCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
