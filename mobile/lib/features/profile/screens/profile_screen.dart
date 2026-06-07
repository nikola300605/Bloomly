import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../community/providers/community_provider.dart';
import '../../community/widgets/article_card.dart';
import '../../home/providers/plants_provider.dart';

/// Read-only profile: avatar, name, stats (plants / posts), and recent posts,
/// followed by the existing settings rows. Editing is post-MVP.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final plantsAsync = ref.watch(plantsProvider);
    final myPostsAsync = ref.watch(myArticlesProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('You'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 20),

                // Avatar
                Center(child: _Avatar(user: user)),
                const SizedBox(height: 12),

                // Name + handle/location
                Center(child: Text(user.name, style: tt.headlineMedium)),
                Center(
                  child: Text(
                    _handleLine(user),
                    style: tt.labelSmall,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Plants',
                          value: plantsAsync.when(
                            data: (p) => '${p.length}',
                            loading: () => '…',
                            error: (_, __) => '–',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Posts',
                          value: myPostsAsync.when(
                            data: (a) => '${a.length}',
                            loading: () => '…',
                            error: (_, __) => '–',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Posts
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Posts', style: tt.headlineSmall),
                ),
                _PostsSection(postsAsync: myPostsAsync),

                const Divider(height: 32),

                // Settings rows (existing functionality)
                ..._rows(context, ref),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  String _handleLine(UserModel user) {
    final location = user.location;
    if (location != null && location.isNotEmpty) {
      return '@${user.handle} · $location';
    }
    return '@${user.handle}';
  }

  List<Widget> _rows(BuildContext context, WidgetRef ref) => [
        _Row(icon: '🌱', label: 'My plants', value: null, onTap: () => context.go(AppRoutes.home)),
        _Row(icon: '📝', label: 'My posts', value: null, onTap: () {}),
        _Row(icon: '🔖', label: 'Saved articles', value: null, onTap: () {}),
        _Row(icon: '🔔', label: 'Notifications', value: null, onTap: () => context.push(AppRoutes.careSchedule)),
        _Row(icon: '📍', label: 'Location & climate', value: null, onTap: () {}),
        _Row(icon: '🌗', label: 'Appearance', value: 'Auto', onTap: () {}),
        _Row(icon: '🔒', label: 'Privacy', value: null, onTap: () {}),
        _Row(icon: '❓', label: 'Help & feedback', value: null, onTap: () {}),
        const Divider(),
        _Row(
          icon: '↩',
          label: 'Sign out',
          value: null,
          onTap: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
          destructive: true,
        ),
      ];
}

/// Large avatar with an initials fallback on a colour derived from the name.
class _Avatar extends StatelessWidget {
  final UserModel user;

  const _Avatar({required this.user});

  static const _palette = [
    Color(0xFF5A8A2E),
    Color(0xFFD97757),
    Color(0xFF5A8FB4),
    Color(0xFF9B59B6),
    Color(0xFFC0392B),
    Color(0xFFE67E22),
  ];

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;
    if (hasAvatar) {
      return CircleAvatar(radius: 44, backgroundImage: NetworkImage(user.avatar!));
    }
    final seed = user.name.isNotEmpty ? user.name : user.handle;
    return CircleAvatar(
      radius: 44,
      backgroundColor: _colorFor(seed),
      child: Text(
        _initials(seed),
        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _colorFor(String seed) {
    if (seed.isEmpty) return _palette.first;
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }

  String _initials(String seed) {
    final parts = seed.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Text(value, style: tt.headlineMedium),
          const SizedBox(height: 2),
          Text(label, style: tt.labelSmall),
        ],
      ),
    );
  }
}

/// Up to 10 most-recent posts, with a "See all" link when there are more.
class _PostsSection extends StatelessWidget {
  final AsyncValue<List<ArticleModel>> postsAsync;

  const _PostsSection({required this.postsAsync});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return postsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Couldn’t load your posts.', style: tt.bodySmall),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('No posts yet.', style: tt.bodySmall),
          );
        }
        final shown = posts.take(10).toList();
        return Column(
          children: [
            for (final article in shown)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ArticleCard(
                  article: article,
                  onTap: () => context.push('/community/articles/${article.id}'),
                ),
              ),
            if (posts.length > 10)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.community),
                    child: const Text('See all'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool destructive;

  const _Row({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 18)),
      title: Text(label, style: TextStyle(fontSize: 14, color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
