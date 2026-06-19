import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/plant_model.dart' show PlantModel;
import '../../../data/models/scan_result_model.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../features/add_plant/add_plant_actions.dart';
import '../../../features/home/providers/plants_provider.dart';
import '../../../shared/widgets/care_badge.dart';
import '../../../shared/widgets/care_guide_card.dart';
import '../../../shared/widgets/error_placeholder.dart';

/// Step 3/3 — AI diagnosis / identification results.
class ScanResultsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ScanResultsScreen({super.key, required this.result});

  ScanResultModel? get _model {
    final raw = result['__scan_result__'];
    if (raw is ScanResultModel) return raw;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final model = _model;
    final tt = Theme.of(context).textTheme;

    if (model == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: ErrorPlaceholder(
          message: "We couldn't read the scan result. Please try again.",
          onRetry: () => context.pop(),
        ),
      );
    }

    if (model.lowConfidence) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔍', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Low confidence — try again', style: tt.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Make sure the plant fills the frame and lighting is good', style: tt.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (model.mode == 'diagnose') {
      return _DiagnosisView(model: model);
    }
    return _IdentifyView(model: model);
  }
}

class _DiagnosisView extends ConsumerStatefulWidget {
  final ScanResultModel model;
  const _DiagnosisView({required this.model});

  @override
  ConsumerState<_DiagnosisView> createState() => _DiagnosisViewState();
}

class _DiagnosisViewState extends ConsumerState<_DiagnosisView> {
  bool _saving = false;

  void _showSnack(String message) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Jumps to the plant's detail screen with fresh data so the new health log
  /// entry is visible.
  void _goToPlant(String plantId, String plantName) {
    ref.invalidate(plantsProvider);
    ref.invalidate(plantDetailProvider(plantId));
    context.go('/home/plants/$plantId');
    _showSnack("Saved to $plantName's health log 🌿");
  }

  Future<void> _saveToPlant() async {
    final model = widget.model;

    setState(() => _saving = true);
    try {
      // When the scan was started from a plant's page, the backend already
      // appended the diagnosis to that plant's health log during /scan/diagnose.
      if (model.plantId != null) {
        final plant = await ref.read(plantRepositoryProvider).getPlant(model.plantId!);
        if (!mounted) return;
        _goToPlant(plant.id, plant.displayName);
        return;
      }

      // Scan came from the generic scan tab — ask which plant to save it to.
      final plants = await ref.read(plantRepositoryProvider).listPlants();
      if (!mounted) return;
      if (plants.isEmpty) {
        setState(() => _saving = false);
        _showSnack('Add a plant first, then you can save diagnoses to it.');
        return;
      }

      setState(() => _saving = false);
      final picked = await _pickPlant(plants);
      if (picked == null || !mounted) return;

      setState(() => _saving = true);
      await ref.read(plantRepositoryProvider).addHealthLog(
            picked.id,
            diagnosis: model.diagnosis,
            notes: model.explanation,
          );
      if (!mounted) return;
      _goToPlant(picked.id, picked.displayName);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(friendlyError(e, fallback: "Couldn't save the diagnosis. Please try again."));
    }
  }

  Future<PlantModel?> _pickPlant(List<PlantModel> plants) {
    return showModalBottomSheet<PlantModel>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Save to which plant?', style: Theme.of(ctx).textTheme.titleLarge),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: plants.length,
                itemBuilder: (_, i) {
                  final p = plants[i];
                  return ListTile(
                    leading: const Text('🪴', style: TextStyle(fontSize: 24)),
                    title: Text(p.displayName),
                    subtitle: Text(p.commonName),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
        children: [
          // Main diagnosis card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🌿', style: TextStyle(fontSize: 48)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CareBadge(
                        kind: 'warn',
                        label: '${((model.confidence ?? 0) * 100).round()}% confident',
                      ),
                      const SizedBox(height: 4),
                      Text(model.diagnosis ?? 'Unknown', style: tt.headlineMedium),
                      if (model.explanation != null)
                        Text(
                          '${model.explanation!.split('.').first}.',
                          style: tt.labelSmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (model.explanation != null) ...[
            Text("What's happening", style: tt.titleLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(model.explanation!, style: tt.bodySmall?.copyWith(height: 1.5)),
            ),
            const SizedBox(height: 16),
          ],

          Text('Try this', style: tt.titleLarge),
          const SizedBox(height: 8),
          ...model.actionSteps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(step.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text(step.description, style: tt.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveToPlant,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save to plant'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.community),
                  child: const Text('Ask community'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentifyView extends ConsumerStatefulWidget {
  final ScanResultModel model;
  const _IdentifyView({required this.model});

  @override
  ConsumerState<_IdentifyView> createState() => _IdentifyViewState();
}

class _IdentifyViewState extends ConsumerState<_IdentifyView> {
  int _selectedIndex = 0;
  bool _saving = false;
  String? _error;

  Future<void> _addPlant() async {
    final candidate = widget.model.topCandidates[_selectedIndex];
    setState(() { _saving = true; _error = null; });
    final error = await addPlantFromPayload(
      ref,
      context,
      {'common_name': candidate.name, 'species': candidate.name},
      displayName: candidate.name,
    );
    if (!mounted) return;
    if (error != null) setState(() { _saving = false; _error = error; });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final candidates = widget.model.topCandidates;
    return Scaffold(
      appBar: AppBar(title: const Text('Identification')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
        children: [
          Text('Top matches — tap to select', style: tt.titleLarge),
          const SizedBox(height: 8),
          ...candidates.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final selected = i == _selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? AppColors.accent : Theme.of(context).dividerColor,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      const Text('🪴', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            if (c.description != null) Text(c.description!, style: tt.labelSmall),
                          ],
                        ),
                      ),
                      CareBadge(kind: 'ok', label: '${(c.confidence * 100).round()}%'),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const CareGuideCard(),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: _saving ? null : _addPlant,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Add ${candidates[_selectedIndex].name}'),
          ),
        ],
      ),
    );
  }
}
