import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../shared/widgets/care_badge.dart';
import '../../../shared/widgets/care_guide_card.dart';
import '../../../shared/widgets/error_placeholder.dart';
import '../../../shared/widgets/plant_thumbnail.dart';
import '../../home/providers/plants_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/next_up_card.dart';
import '../widgets/recommendations_card.dart';

/// Variation B — modular card stack (recommended in design handoff).
class PlantDetailScreen extends ConsumerWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantDetailProvider(plantId));
    final repo = ref.read(plantRepositoryProvider);

    return Scaffold(
      body: plantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorPlaceholder(
          message: friendlyError(e, fallback: "Couldn't load this plant. Try again."),
          onRetry: () => ref.invalidate(plantDetailProvider(plantId)),
        ),
        data: (plant) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              title: Text(plant.displayName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showOptions(context, ref, repo),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Identity strip
                    Row(
                      children: [
                        PlantThumbnail(photoUrl: plant.photoUrl, size: 66),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plant.species, style: Theme.of(context).textTheme.headlineSmall),
                              if (plant.location != null)
                                Text(
                                  '${plant.location} · ${plant.ageOrAcquiredAt ?? ""}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              const SizedBox(height: 4),
                              if (plant.nextCareBadge != null)
                                CareBadge(kind: plant.nextCareBadge!.kind, label: plant.nextCareBadge!.label),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Next up card
                    NextUpCard(
                      plant: plant,
                      onMarkDone: (kind) async {
                        await repo.markCareDone(plant.id, kind);
                        ref.invalidate(plantDetailProvider(plantId));
                      },
                      onSnooze: (kind) async {
                        await repo.snooze(plant.id, kind);
                        ref.invalidate(plantDetailProvider(plantId));
                      },
                    ),
                    const SizedBox(height: 12),

                    // Recommendations card
                    RecommendationsCard(plant: plant),
                    const SizedBox(height: 12),

                    // Care guide — watering / fertilizing cadence at a glance
                    CareGuideCard(schedule: plant.careSchedule),
                    const SizedBox(height: 12),

                    // Health card
                    HealthCard(plant: plant),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, PlantRepository repo) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit plant'),
            onTap: () {
              Navigator.pop(context);
              // TODO: push edit plant screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete plant', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await repo.deletePlant(plantId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
