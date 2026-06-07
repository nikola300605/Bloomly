import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/widgets/error_placeholder.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/community_provider.dart';
import '../widgets/article_card.dart';

const _filters = [
  ('null', 'for you'),
  ('following', 'following'),
  ('questions', 'questions'),
  ('how_to', 'how-to'),
];

/// Variation A — article list with filter chips (recommended).
class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(communityFeedProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.writeArticle),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = (_filter == null && f.$1 == 'null') || _filter == f.$1;
                return FilterChip(
                  label: Text(f.$2),
                  selected: active,
                  onSelected: (_) => setState(() => _filter = f.$1 == 'null' ? null : f.$1),
                );
              },
            ),
          ),

          // Feed
          Expanded(
            child: feedAsync.when(
              loading: () => ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ArticleCardSkeleton(),
                ),
              ),
              error: (e, _) => ErrorPlaceholder(
                message: friendlyError(e, fallback: "Couldn't load posts. Try again."),
                onRetry: () => ref.invalidate(communityFeedProvider(_filter)),
              ),
              data: (articles) {
                if (articles.isEmpty) {
                  return const Center(child: Text('No articles yet — be the first to post!'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 80),
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => ArticleCard(
                    article: articles[i],
                    onTap: () => context.push('/community/articles/${articles[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
