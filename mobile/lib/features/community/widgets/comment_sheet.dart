import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/time_ago.dart';
import '../../../data/models/article_model.dart';
import '../../../shared/widgets/error_placeholder.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/comments_provider.dart';

/// Bottom sheet showing an article's comments plus a pinned input field.
/// Opened from the comment action on the article screen.
class CommentSheet extends ConsumerStatefulWidget {
  final String articleId;

  const CommentSheet({super.key, required this.articleId});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Rebuild so the send button enables/disables as the user types.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final user = ref.read(authProvider).user;
    final optimistic = CommentModel(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      articleId: widget.articleId,
      authorId: user?.id ?? '',
      authorHandle: user?.handle ?? 'you',
      authorAvatar: user?.avatar,
      body: text,
      createdAt: DateTime.now(),
    );

    _controller.clear();
    setState(() => _sending = true);
    final ok = await ref
        .read(commentsProvider(widget.articleId).notifier)
        .addComment(text, optimistic);
    if (!mounted) return;
    setState(() => _sending = false);

    if (!ok) {
      // Restore the text so the user can retry, and tell them what happened.
      _controller.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't post your comment. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.articleId));
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Grabber
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  Text('Comments', style: tt.headlineSmall),
                  const SizedBox(width: 8),
                  if (!state.loading && state.error == null)
                    Text('${state.comments.length}', style: tt.labelSmall),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(state)),
            const Divider(height: 1),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CommentsState state) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return ErrorPlaceholder(
        message: friendlyError(state.error!, fallback: "Couldn't load comments. Try again."),
        onRetry: () => ref.read(commentsProvider(widget.articleId).notifier).load(),
      );
    }
    if (state.comments.isEmpty) {
      return Center(
        child: Text(
          'Be the first to comment.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      itemCount: state.comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _CommentTile(comment: state.comments[i]),
    );
  }

  Widget _buildInput() {
    final canSend = _controller.text.trim().isNotEmpty && !_sending;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Add a comment…',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canSend ? _send : null,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasAvatar = comment.authorAvatar != null && comment.authorAvatar!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cs.secondary,
          backgroundImage: hasAvatar ? NetworkImage(comment.authorAvatar!) : null,
          child: hasAvatar
              ? null
              : Text(
                  comment.authorHandle.isNotEmpty ? comment.authorHandle[0].toUpperCase() : '?',
                  style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '@${comment.authorHandle}',
                      style: tt.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo(comment.createdAt),
                    style: tt.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(comment.body, style: tt.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
