import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/scan_result_model.dart';
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

class _DiagnosisView extends StatelessWidget {
  final ScanResultModel model;
  const _DiagnosisView({required this.model});

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    // TODO: save to plant health log
                    Navigator.pop(context);
                  },
                  child: const Text('Save to plant'),
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

class _IdentifyView extends StatelessWidget {
  final ScanResultModel model;
  const _IdentifyView({required this.model});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Identification')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
        children: [
          Text('Top matches', style: tt.titleLarge),
          const SizedBox(height: 8),
          ...model.topCandidates.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
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
                      CareBadge(
                        kind: 'ok',
                        label: '${(c.confidence * 100).round()}%',
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),

          // Care guide — surfaces care basics right after identification.
          const CareGuideCard(),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => context.push(AppRoutes.addPlant),
            child: const Text('Add this plant'),
          ),
        ],
      ),
    );
  }
}
