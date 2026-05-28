import 'package:flutter/material.dart';
import '../../../data/models/plant_model.dart';
import '../../../shared/widgets/care_badge.dart' as care_widgets;
import '../../../shared/widgets/plant_thumbnail.dart';

class PlantListTile extends StatelessWidget {
  final PlantModel plant;
  final VoidCallback onTap;

  const PlantListTile({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            PlantThumbnail(photoUrl: plant.photoUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.displayName, style: Theme.of(context).textTheme.bodyMedium),
                  if (plant.location != null) ...[
                    const SizedBox(height: 2),
                    Text(plant.location!, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ],
              ),
            ),
            if (plant.nextCareBadge != null)
              care_widgets.CareBadge(kind: plant.nextCareBadge!.kind, label: plant.nextCareBadge!.label)
            else
              const care_widgets.CareBadge(kind: 'ok', label: '✓ happy'),
          ],
        ),
      ),
    );
  }
}
