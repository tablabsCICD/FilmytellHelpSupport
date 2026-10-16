import '../core/constants/app_constants.dart';
import '../models/knowledge_base_article.dart';
import '../services/storage_service.dart';

class KnowledgeBaseRepository {
  final StorageService _storageService;
  List<KnowledgeBaseArticle> _articles = [];
  bool _isInitialized = false;

  KnowledgeBaseRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<List<KnowledgeBaseArticle>> getArticles({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh && _articles.isNotEmpty) {
      return _articles;
    }

    await _storageService.init();
    final localData = _storageService.getJson(AppConstants.keyKbArticles);

    if (localData != null && localData is List && localData.isNotEmpty && !forceRefresh) {
      _articles = localData.map((e) => KnowledgeBaseArticle.fromJson(e as Map<String, dynamic>)).toList();
      _isInitialized = true;
      return _articles;
    }

    _articles = [];
    _isInitialized = true;
    return _articles;
  }

  Future<void> addArticle(KnowledgeBaseArticle article) async {
    _articles.insert(0, article);
    await _saveToStorage();
  }

  Future<void> updateArticle(KnowledgeBaseArticle updated) async {
    final index = _articles.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _articles[index] = updated;
      await _saveToStorage();
    }
  }

  Future<void> deleteArticle(String id) async {
    _articles.removeWhere((a) => a.id == id);
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final list = _articles.map((a) => a.toJson()).toList();
    await _storageService.setJson(AppConstants.keyKbArticles, list);
  }
}
