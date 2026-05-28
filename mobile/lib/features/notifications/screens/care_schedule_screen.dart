import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../shared/widgets/care_badge.dart';

/// Variation A — chronological timeline with Today + This week sections.
class CareScheduleScreen extends ConsumerWidget {
  const CareScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(plantRepositoryProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {})],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: repo.getCareTasksAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final tasks = snap.data ?? [];
          final today = tasks.where((t) => _isToday(t)).toList();
          final week = tasks.where((t) => _isThisWeek(t) && !_isToday(t)).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
            children: [
              if (today.isEmpty && week.isEmpty)
                _EmptyState()
              else ...[
                if (today.isNotEmpty) ...[
                  Text('Today', style: tt.titleLarge),
                  const SizedBox(height: 8),
                  ...today.map((t) => _TaskTile(
                        task: t,
                        onDone: () async {
                          await repo.markCareDone(t['plant_id'] as String, t['kind'] as String);
                          (context as Element).markNeedsBuild();
                        },
                        onSnooze: () async {
                          await repo.snooze(t['plant_id'] as String, t['kind'] as String);
                        },
                      )),
                  const SizedBox(height: 16),
                ],
                if (week.isNotEmpty) ...[
                  Text('This week', style: tt.titleLarge),
                  const SizedBox(height: 8),
                  ...week.map((t) => _WeekTaskTile(task: t)),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  bool _isToday(Map<String, dynamic> t) {
    try {
      final due = DateTime.parse(t['due_at'] as String);
      final now = DateTime.now();
      return due.year == now.year && due.month == now.month && due.day == now.day ||
          due.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  bool _isThisWeek(Map<String, dynamic> t) {
    try {
      final due = DateTime.parse(t['due_at'] as String);
      final endOfWeek = DateTime.now().add(const Duration(days: 7));
      return due.isBefore(endOfWeek);
    } catch (_) {
      return false;
    }
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onDone;
  final VoidCallback onSnooze;

  const _TaskTile({required this.task, required this.onDone, required this.onSnooze});

  @override
  Widget build(BuildContext context) {
    final kind = task['kind'] as String? ?? '';
    final icon = _icon(kind);
    final plantName = task['plant_name'] as String? ?? 'Plant';
    final badgeKind = task['badge_kind'] as String? ?? 'info';
    final badgeLabel = task['badge_label'] as String? ?? kind;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_capitalize(kind)} $plantName', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  CareBadge(kind: badgeKind, label: badgeLabel),
                ],
              ),
            ),
            TextButton(
              onPressed: onDone,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: const StadiumBorder(),
              ),
              child: const Text('✓', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekTaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  const _WeekTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final kind = task['kind'] as String? ?? '';
    final icon = _icon(kind);
    final plantName = task['plant_name'] as String? ?? 'Plant';
    final due = DateTime.tryParse(task['due_at'] as String? ?? '') ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                _dayLabel(due),
                style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${_capitalize(kind)} $plantName', style: Theme.of(context).textTheme.bodySmall),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('snooze'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('✓', style: TextStyle(fontSize: 64, color: AppColors.ok)),
            const SizedBox(height: 16),
            Text('All caught up!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('No care tasks due', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

String _icon(String kind) => switch (kind) {
      'water' => '💧',
      'fertilize' => '🧂',
      'rotate' => '☀',
      'prune' => '✂',
      _ => '•',
    };

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _dayLabel(DateTime dt) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[dt.weekday - 1];
}
