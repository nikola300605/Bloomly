import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/plant_model.dart';

/// Card that surfaces a plant's care information as labelled, icon-led rows.
///
/// Pass a [schedule] to show the plant's real care intervals (used on the plant
/// detail screen). Omit it to show general care basics — used right after
/// identification, where no per-plant schedule exists yet.
class CareGuideCard extends StatelessWidget {
  final CareSchedule? schedule;

  const CareGuideCard({super.key, this.schedule});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final rows = _rows();

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
          Text('Care guide', style: tt.titleLarge),
          const SizedBox(height: 12),
          for (final r in rows) ...[
            _CareRow(data: r),
            if (r != rows.last) const SizedBox(height: 12),
          ],
          if (schedule == null) ...[
            const SizedBox(height: 12),
            Text(
              'Add this plant to get a personalised care schedule.',
              style: tt.labelSmall,
            ),
          ],
        ],
      ),
    );
  }

  List<_CareRowData> _rows() {
    final s = schedule;
    if (s != null) {
      return [
        _CareRowData(Icons.water_drop_outlined, 'Water', _everyDays(s.water.intervalDays)),
        _CareRowData(Icons.eco_outlined, 'Fertilize', _everyDays(s.fertilize.intervalDays)),
        if (s.rotate != null)
          _CareRowData(Icons.rotate_right, 'Rotate', _everyDays(s.rotate!.intervalDays)),
        if (s.prune != null)
          _CareRowData(Icons.content_cut, 'Prune', _everyDays(s.prune!.intervalDays)),
      ];
    }
    // General basics shown right after identification.
    return const [
      _CareRowData(Icons.wb_sunny_outlined, 'Light', 'Bright, indirect light'),
      _CareRowData(Icons.water_drop_outlined, 'Water', 'When the top inch is dry'),
      _CareRowData(Icons.spa_outlined, 'Soil', 'Well-draining potting mix'),
    ];
  }

  /// Turns an interval in days into a human-readable cadence.
  static String _everyDays(int days) {
    if (days <= 0) return 'As needed';
    if (days == 1) return 'Every day';
    return 'Every $days days';
  }
}

class _CareRowData {
  final IconData icon;
  final String label;
  final String value;

  const _CareRowData(this.icon, this.label, this.value);
}

class _CareRow extends StatelessWidget {
  final _CareRowData data;

  const _CareRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(data.icon, size: 20, color: AppColors.accent),
            const SizedBox(width: 12),
            Text(data.label, style: tt.labelLarge),
          ],
        ),
        Flexible(
          child: Text(
            data.value,
            textAlign: TextAlign.right,
            style: tt.bodySmall,
          ),
        ),
      ],
    );
  }
}
