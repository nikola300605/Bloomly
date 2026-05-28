import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/plants_provider.dart';
import '../widgets/plant_list_tile.dart';

/// Variation A — list with inline care badges (recommended).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: plantsAsync.when(
                        data: (plants) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey 👋', style: tt.headlineLarge),
                            Text(
                              '${plants.length} plants · ${plants.where((p) => p.nextCareBadge?.kind == 'bad' || p.nextCareBadge?.kind == 'warn').length} need attention',
                              style: tt.labelSmall,
                            ),
                          ],
                        ),
                        loading: () => const PlantListTileSkeleton(),
                        error: (_, __) => Text('Error loading plants', style: tt.bodySmall),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.push(AppRoutes.careSchedule),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search plants…',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                  readOnly: true,
                  onTap: () {
                    // TODO: push plant search screen
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Plant list
            plantsAsync.when(
              data: (plants) {
                if (plants.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(onAddPlant: () => context.push(AppRoutes.addPlant)),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverList.separated(
                    itemCount: plants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => PlantListTile(
                      plant: plants[i],
                      onTap: () => context.push('/home/plants/${plants[i].id}'),
                    ),
                  ),
                );
              },
              loading: () => SliverList.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const PlantListTileSkeleton(),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Could not load plants.\n$e', textAlign: TextAlign.center)),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addPlant),
        icon: const Icon(Icons.add),
        label: const Text('Add plant'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPlant;
  const _EmptyState({required this.onAddPlant});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🪴', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text('No plants yet', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Add your first plant to get started', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onAddPlant, child: const Text('Add a plant')),
      ],
    );
  }
}
