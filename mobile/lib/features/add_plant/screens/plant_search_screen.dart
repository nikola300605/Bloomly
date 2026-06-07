import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/error_handler.dart';
import '../../../data/models/species_model.dart';
import '../../../shared/widgets/error_placeholder.dart';
import '../add_plant_actions.dart';
import '../providers/catalog_provider.dart';

/// Search the built-in species catalog and add a plant in one tap.
class PlantSearchScreen extends ConsumerStatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  ConsumerState<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends ConsumerState<PlantSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _addingId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SpeciesModel> _filter(List<SpeciesModel> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((s) =>
            s.commonName.toLowerCase().contains(q) || s.species.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _add(SpeciesModel s) async {
    setState(() => _addingId = s.id);
    final error = await addPlantFromPayload(
      ref,
      context,
      s.toCreatePayload(),
      displayName: s.commonName,
    );
    if (!mounted) return;
    setState(() => _addingId = null);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search plants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search our catalog…',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: catalogAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorPlaceholder(
                message: friendlyError(e, fallback: "Couldn't load the catalog. Try again."),
                onRetry: () => ref.invalidate(catalogProvider),
              ),
              data: (all) {
                final results = _filter(all);
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No plants match "$_query".',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _SpeciesTile(
                    species: results[i],
                    adding: _addingId == results[i].id,
                    onAdd: () => _add(results[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeciesTile extends StatelessWidget {
  final SpeciesModel species;
  final bool adding;
  final VoidCallback onAdd;

  const _SpeciesTile({required this.species, required this.adding, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: species.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: species.photoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 56,
                      height: 56,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    errorWidget: (_, __, ___) => _emojiBox(context),
                  )
                : _emojiBox(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(species.commonName, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(species.species, style: tt.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(context, species.difficulty),
                    if (species.petSafe) _chip(context, 'Pet-safe'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: adding ? null : onAdd,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(64, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: adding
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiBox(BuildContext context) => Container(
        width: 56,
        height: 56,
        color: Theme.of(context).colorScheme.secondary,
        alignment: Alignment.center,
        child: Text(species.emoji, style: const TextStyle(fontSize: 26)),
      );

  Widget _chip(BuildContext context, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      );
}
