import 'package:flutter/material.dart';
import '../../../data/models/article_model.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    article.authorHandle?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 6),
                Text('@${article.authorHandle ?? 'unknown'}', style: tt.labelSmall),
                const SizedBox(width: 4),
                Text('· ${_timeAgo(article.createdAt)}', style: tt.labelSmall?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(article.title, style: tt.titleLarge?.copyWith(height: 1.2)),

            // Tags
            if (article.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                article.tags.map((t) => '#$t').join(' · '),
                style: tt.labelSmall,
              ),
            ],

            const SizedBox(height: 8),

            // Engagement row
            Row(
              children: [
                Icon(Icons.favorite_border, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text('${article.likeCount}', style: tt.labelSmall),
                const SizedBox(width: 12),
                Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text('${article.commentCount}', style: tt.labelSmall),
                const SizedBox(width: 12),
                Icon(Icons.share_outlined, size: 14, color: Colors.grey.shade500),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}
