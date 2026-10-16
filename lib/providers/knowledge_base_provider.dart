import 'package:flutter/material.dart';
import '../models/knowledge_base_article.dart';
import '../repositories/knowledge_base_repository.dart';

class KnowledgeBaseProvider extends ChangeNotifier {
  final KnowledgeBaseRepository _repository;

  List<KnowledgeBaseArticle> _articles = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  KnowledgeBaseProvider({KnowledgeBaseRepository? repository})
      : _repository = repository ?? KnowledgeBaseRepository() {
    loadArticles();
  }

  List<KnowledgeBaseArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<KnowledgeBaseArticle> get filteredArticles {
    return _articles.where((article) {
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchTitle = article.title.toLowerCase().contains(query);
        final matchContent = article.content.toLowerCase().contains(query);
        final matchTag = article.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchTitle && !matchContent && !matchTag) return false;
      }
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty && _selectedCategory != 'All') {
        if (article.category != _selectedCategory) return false;
      }
      return true;
    }).toList();
  }

  Future<void> loadArticles({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _articles = await _repository.getArticles(forceRefresh: forceRefresh);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addArticle(KnowledgeBaseArticle article) async {
    await _repository.addArticle(article);
    await loadArticles();
  }

  Future<void> updateArticle(KnowledgeBaseArticle article) async {
    await _repository.updateArticle(article);
    await loadArticles();
  }

  Future<void> deleteArticle(String id) async {
    await _repository.deleteArticle(id);
    await loadArticles();
  }
}
