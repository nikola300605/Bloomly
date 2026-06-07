import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/article_model.dart';
import '../../../data/repositories/article_repository.dart';

final communityFeedProvider = FutureProvider.family<List<ArticleModel>, String?>((ref, filter) {
  return ref.read(articleRepositoryProvider).listArticles(filter: filter);
});

final articleDetailProvider = FutureProvider.family<ArticleModel, String>((ref, articleId) {
  return ref.read(articleRepositoryProvider).getArticle(articleId);
});

/// The current user's own articles (for the profile screen).
final myArticlesProvider = FutureProvider<List<ArticleModel>>((ref) {
  return ref.read(articleRepositoryProvider).listMyArticles();
});
