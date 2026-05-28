import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/article_repository.dart';

/// Variation A — plain title + body editor (recommended for MVP).
class WriteArticleScreen extends ConsumerStatefulWidget {
  const WriteArticleScreen({super.key});

  @override
  ConsumerState<WriteArticleScreen> createState() => _WriteArticleScreenState();
}

class _WriteArticleScreenState extends ConsumerState<WriteArticleScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New post'),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        leadingWidth: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _posting ? null : _post,
              child: _posting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover photo placeholder
                  GestureDetector(
                    onTap: () {
                      // TODO: image picker
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 32),
                          const SizedBox(height: 6),
                          Text('tap to add a cover photo', style: tt.labelSmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Title…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: tt.headlineLarge?.copyWith(height: 1.2),
                    maxLines: null,
                  ),

                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 8),

                  // Body
                  TextField(
                    controller: _bodyCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Tell your story… what went well, what didn\'t, what you learned 🌱',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: tt.bodyMedium?.copyWith(height: 1.65),
                    maxLines: null,
                    minLines: 12,
                  ),
                ],
              ),
            ),
          ),

          // Formatting toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                _FmtBtn(icon: Icons.format_bold, onTap: () {}),
                _FmtBtn(icon: Icons.format_italic, onTap: () {}),
                _FmtBtn(icon: Icons.format_list_bulleted, onTap: () {}),
                _FmtBtn(icon: Icons.format_list_numbered, onTap: () {}),
                _FmtBtn(icon: Icons.link, onTap: () {}),
                _FmtBtn(icon: Icons.image_outlined, onTap: () {}),
                _FmtBtn(icon: Icons.eco_outlined, onTap: () {}), // plant-link
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a title')));
      return;
    }
    setState(() => _posting = true);
    try {
      final article = await ref.read(articleRepositoryProvider).createArticle({
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'tags': [],
        'linked_plant_ids': [],
      });
      if (mounted) {
        context.pop();
        context.push('/community/articles/${article.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
        setState(() => _posting = false);
      }
    }
  }
}

class _FmtBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FmtBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon, size: 20), onPressed: onTap, visualDensity: VisualDensity.compact);
  }
}
