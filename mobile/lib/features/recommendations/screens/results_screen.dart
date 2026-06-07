import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/species_model.dart';
import '../../../shared/widgets/care_badge.dart';
import '../../../shared/widgets/error_placeholder.dart';
import '../../add_plant/add_plant_actions.dart';
import '../../add_plant/providers/catalog_provider.dart';

/// Variation C — plant match % results after the quiz, driven by the catalog.
class QuizResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> answers;

  const QuizResultsScreen({super.key, required this.answers});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  String? _addingId;

  /// Scores a species against the quiz answers; higher is a better match.
  int _score(SpeciesModel s) {
    final a = widget.answers;
    final pets = a['pets'] as String?;
    final sun = a['sun'] as String?;
    final commitment = a['commitment'] as String?;
    final location = a['location'] as String?;
    var score = 60;

    if (pets != null && pets != 'None') {
      score += s.petSafe ? 25 : -30;
    }

    switch (commitment) {
      case 'Forget it':
        if (s.difficulty == 'Easy') score += 20;
        if (s.difficulty == 'Hard') score -= 25;
        break;
      case 'Weekly':
        if (s.difficulty != 'Hard') score += 10;
        break;
      case 'Daily':
      case 'Expert':
        if (s.difficulty == 'Hard') score += 12;
        break;
    }

    switch (sun) {
      case 'Barely any':
        if (s.light == 'low') {
          score += 22;
        } else if (s.light == 'bright' || s.light == 'full-sun') {
          score -= 22;
        }
        break;
      case 'A little':
        if (s.light == 'indirect' || s.light == 'low') {
          score += 15;
        } else if (s.light == 'full-sun') {
          score -= 12;
        }
        break;
      case 'Lots':
      case 'Outdoor full sun':
        if (s.light == 'full-sun' || s.light == 'bright') {
          score += 20;
        } else if (s.light == 'low') {
          score -= 6;
        }
        break;
    }

    if (location == 'Bathroom' && s.humidity) score += 15;

    return score.clamp(40, 99);
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
    final tt = Theme.of(context).textTheme;
    final summary = widget.answers.entries.map((e) => e.value).join(' · ');
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.pop(),
            tooltip: 'Redo quiz',
          ),
        ],
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorPlaceholder(
          message: friendlyError(e, fallback: "Couldn't load recommendations. Try again."),
          onRetry: () => ref.invalidate(catalogProvider),
        ),
        data: (all) {
          final ranked = [...all]..sort((x, y) => _score(y).compareTo(_score(x)));
          final matches = ranked.take(6).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  text: TextSpan(
                    style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(text: 'Based on: ', style: tt.titleLarge?.copyWith(fontSize: 13)),
                      TextSpan(text: summary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...matches.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MatchCard(
                      species: s,
                      match: _score(s),
                      adding: _addingId == s.id,
                      onAdd: () => _add(s),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final SpeciesModel species;
  final int match;
  final bool adding;
  final VoidCallback onAdd;

  const _MatchCard({
    required this.species,
    required this.match,
    required this.adding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(species.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(species.commonName,
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    CareBadge(kind: 'ok', label: '$match% match'),
                  ],
                ),
                const SizedBox(height: 4),
                if (species.description != null)
                  Text(species.description!, style: tt.labelSmall),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: adding ? null : onAdd,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: adding
                        ? const SizedBox(
                            width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('+ Add to my plants'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
