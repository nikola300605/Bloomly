import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/article_model.dart';
import '../../../data/repositories/article_repository.dart';

/// State for an article's comment list.
class CommentsState {
  final bool loading;
  final List<CommentModel> comments;
  final Object? error;

  const CommentsState({
    this.loading = false,
    this.comments = const [],
    this.error,
  });
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final ArticleRepository _repo;
  final String _articleId;

  CommentsNotifier(this._repo, this._articleId) : super(const CommentsState(loading: true)) {
    load();
  }

  Future<void> load() async {
    state = const CommentsState(loading: true);
    try {
      final comments = await _repo.getComments(_articleId);
      state = CommentsState(comments: comments);
    } catch (e) {
      state = CommentsState(error: e);
    }
  }

  /// Optimistically appends [optimistic], then confirms with the API. Returns
  /// true on success (the optimistic entry is swapped for the saved one). On
  /// failure the optimistic entry is removed and false is returned.
  Future<bool> addComment(String body, CommentModel optimistic) async {
    state = CommentsState(comments: [...state.comments, optimistic]);
    try {
      final saved = await _repo.addComment(_articleId, body);
      state = CommentsState(comments: [
        for (final c in state.comments)
          if (c.id == optimistic.id) saved else c,
      ]);
      return true;
    } catch (_) {
      state = CommentsState(
        comments: state.comments.where((c) => c.id != optimistic.id).toList(),
      );
      return false;
    }
  }
}

final commentsProvider = StateNotifierProvider.autoDispose
    .family<CommentsNotifier, CommentsState, String>((ref, articleId) {
  return CommentsNotifier(ref.read(articleRepositoryProvider), articleId);
});
