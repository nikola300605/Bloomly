import 'package:flutter/material.dart';
import '../../../data/models/plant_model.dart';

/// Static care recommendations for a plant species.
/// In a full implementation these would be fetched from the species catalog.
class RecommendationsCard extends StatelessWidget {
  final PlantModel plant;

  const RecommendationsCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Placeholder recommendations — replace with species-catalog API call
    final recs = [
      '· Well-draining potting mix',
      '· Diluted balanced fertilizer (10-10-10) monthly',
      '· Bright indirect light',
    ];

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
          Text('Recommended for ${plant.displayName}', style: tt.titleLarge),
          const SizedBox(height: 8),
          ...recs.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(r, style: tt.bodySmall),
              )),
        ],
      ),
    );
  }
}
