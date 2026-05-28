import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/plant_model.dart';

/// Health card — shows last scan result and a "Scan again" CTA.
class HealthCard extends StatelessWidget {
  final PlantModel plant;

  const HealthCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lastScan = plant.healthLog.isNotEmpty ? plant.healthLog.last : null;

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
          Text('Health', style: tt.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last scan', style: tt.labelSmall),
                    Text(
                      lastScan != null
                          ? '${_daysAgo(lastScan.timestamp)}d ago · ${lastScan.diagnosis ?? 'healthy'}'
                          : 'Never scanned',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '${AppRoutes.scan}?mode=diagnose&plantId=${plant.id}',
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Scan again'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _daysAgo(DateTime dt) => DateTime.now().difference(dt).inDays;
}
