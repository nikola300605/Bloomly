import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/plant_model.dart';

/// "Next up" card — shows the 1-2 most urgent care tasks with mark-done / snooze.
class NextUpCard extends StatelessWidget {
  final PlantModel plant;
  final void Function(String kind) onMarkDone;
  final void Function(String kind) onSnooze;

  const NextUpCard({
    super.key,
    required this.plant,
    required this.onMarkDone,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = plant.careSchedule;
    final tasks = _urgentTasks(cs);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next up', style: tt.titleLarge),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Text('✓ All caught up!', style: tt.bodySmall?.copyWith(color: AppColors.ok))
          else
            ...tasks.map((t) => _TaskRow(
                  task: t,
                  onDone: () => onMarkDone(t.kind),
                  onSnooze: () => onSnooze(t.kind),
                )),
        ],
      ),
    );
  }

  List<_TaskInfo> _urgentTasks(CareSchedule cs) {
    final now = DateTime.now();
    final result = <_TaskInfo>[];

    void check(CareInterval? interval, String kind, String icon) {
      if (interval == null) return;
      final due = interval.nextDue;
      final daysLeft = due.difference(now).inDays;
      if (daysLeft <= 2) {
        result.add(_TaskInfo(
          kind: kind,
          icon: icon,
          label: daysLeft < 0
              ? '$icon $kind overdue'
              : daysLeft == 0
                  ? '$icon $kind today'
                  : '$icon $kind in ${daysLeft}d',
          due: due,
        ));
      }
    }

    check(cs.water, 'water', '💧');
    check(cs.fertilize, 'fertilize', '🧂');
    if (cs.rotate != null) check(cs.rotate, 'rotate', '☀');
    if (cs.prune != null) check(cs.prune, 'prune', '✂');
    result.sort((a, b) => a.due.compareTo(b.due));
    return result.take(2).toList();
  }
}

class _TaskInfo {
  final String kind;
  final String icon;
  final String label;
  final DateTime due;

  const _TaskInfo({required this.kind, required this.icon, required this.label, required this.due});
}

class _TaskRow extends StatelessWidget {
  final _TaskInfo task;
  final VoidCallback onDone;
  final VoidCallback onSnooze;

  const _TaskRow({required this.task, required this.onDone, required this.onSnooze});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(task.label, style: Theme.of(context).textTheme.bodySmall)),
          TextButton(
            onPressed: onDone,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('✓ done'),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: onSnooze,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Snooze'),
          ),
        ],
      ),
    );
  }
}
