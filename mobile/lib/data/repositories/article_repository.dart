import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/article_model.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.read(apiClientProvider));
});

class ArticleRepository {
  final ApiClient _api;
  ArticleRepository(this._api);

  Future<List<ArticleModel>> listArticles({String? filter, int skip = 0, int limit = 20}) async {
    final res = await _api.get('/articles/', queryParameters: {
      if (filter != null) 'filter': filter,
      'skip': skip,
      'limit': limit,
    });
    return (res.data as List).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ArticleModel> getArticle(String articleId) async {
    final res = await _api.get('/articles/$articleId');
    return ArticleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ArticleModel>> listMyArticles({int skip = 0, int limit = 20}) async {
    final res = await _api.get('/articles/mine', queryParameters: {'skip': skip, 'limit': limit});
    return (res.data as List).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ArticleModel> createArticle(Map<String, dynamic> data) async {
    final res = await _api.post('/articles/', data: data);
    return ArticleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ArticleModel> updateArticle(String articleId, Map<String, dynamic> data) async {
    final res = await _api.patch('/articles/$articleId', data: data);
    return ArticleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteArticle(String articleId) => _api.delete('/articles/$articleId');

  Future<bool> toggleLike(String articleId) async {
    final res = await _api.post('/articles/$articleId/like');
    return res.data['liked'] as bool;
  }

  Future<bool> toggleSave(String articleId) async {
    final res = await _api.post('/articles/$articleId/save');
    return res.data['saved'] as bool;
  }

  Future<List<CommentModel>> getComments(String articleId) async {
    final res = await _api.get('/articles/$articleId/comments');
    return (res.data as List).map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommentModel> addComment(String articleId, String body) async {
    final res = await _api.post('/articles/$articleId/comments', data: {'body': body});
    return CommentModel.fromJson(res.data as Map<String, dynamic>);
  }
}
