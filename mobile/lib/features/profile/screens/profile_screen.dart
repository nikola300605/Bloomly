import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';

/// Variation A — settings-style list (recommended for MVP).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('You'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          // Avatar + name header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                  child: user?.avatar == null
                      ? const Text('🌿', style: TextStyle(fontSize: 22))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Gardener', style: tt.headlineMedium),
                      Text(
                        '@${user?.handle ?? 'user'} · ${user?.location ?? ''}',
                        style: tt.labelSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
              ],
            ),
          ),

          const Divider(),

          // Settings rows
          ..._rows(context, ref),
        ],
      ),
    );
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
