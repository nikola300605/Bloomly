import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/article_repository.dart';
import '../providers/community_provider.dart';

/// Variation A — long-form reading experience with sticky bottom action bar.
class ArticleScreen extends ConsumerWidget {
  final String articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));
    final repo = ref.read(articleRepositoryProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (article) => Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: article.coverPhoto != null ? 200 : 0,
                  flexibleSpace: article.coverPhoto != null
                      ? FlexibleSpaceBar(
                          background: Image.network(article.coverPhoto!, fit: BoxFit.cover),
                        )
                      : null,
                  actions: [
                    IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                    IconButton(
                      icon: Icon(article.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: article.isLiked ? AppColors.danger : null),
                      onPressed: () async {
                        await repo.toggleLike(articleId);
                        ref.invalidate(articleDetailProvider(articleId));
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.title, style: tt.displayMedium?.copyWith(height: 1.1)),
                        const SizedBox(height: 8),
                        Text(
                          'by @${article.authorHandle ?? 'unknown'} · ${_readTime(article.body)} min read',
                          style: tt.labelSmall,
                        ),
                        const SizedBox(height: 20),
                        Text(article.body, style: tt.bodyMedium?.copyWith(height: 1.65)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky bottom action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionItem(
                      icon: article.isLiked ? Icons.favorite : Icons.favorite_border,
                      label: '${article.likeCount}',
                      color: article.isLiked ? AppColors.danger : null,
                      onTap: () async {
                        await repo.toggleLike(articleId);
                        ref.invalidate(articleDetailProvider(articleId));
                      },
                    ),
                    _ActionItem(
                      icon: Icons.chat_bubble_outline,
                      label: '${article.commentCount}',
                      onTap: () {
                        // TODO: show comments sheet
                      },
                    ),
                    _ActionItem(
                      icon: article.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: article.isSaved ? AppColors.accent : null,
                      onTap: () async {
                        await repo.toggleSave(articleId);
                        ref.invalidate(articleDetailProvider(articleId));
                      },
                    ),
                    _ActionItem(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _readTime(String body) => (body.split(' ').length / 200).ceil().clamp(1, 99);
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.onSurface),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
