import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/scan_provider.dart';

const _symptoms = [
  ('🟡', 'yellow leaves'),
  ('🟤', 'brown tips'),
  ('🪲', 'bugs'),
  ('🥀', 'wilting'),
  ('🔘', 'spots'),
  ('🦠', 'mold'),
  ('🌿', 'leggy growth'),
];

/// Step 2/3 — guided symptom picker before AI analysis.
class ScanSymptomsScreen extends ConsumerStatefulWidget {
  final String photoPath;
  final String? plantId;

  const ScanSymptomsScreen({super.key, required this.photoPath, this.plantId});

  @override
  ConsumerState<ScanSymptomsScreen> createState() => _ScanSymptomsScreenState();
}

class _ScanSymptomsScreenState extends ConsumerState<ScanSymptomsScreen> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnose'),
        actions: [TextButton(onPressed: _analyze, child: const Text('Skip'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          // Progress bar
          Row(children: List.generate(3, (i) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              color: i < 2 ? AppColors.accent : Colors.grey.shade300,
            ),
          ))),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step 2 of 3', style: tt.labelSmall),
            ],
          ),
          const SizedBox(height: 16),
          Text("What's wrong?", style: tt.headlineMedium),
          Text("Pick all that apply — helps the AI focus", style: tt.labelSmall),
          const SizedBox(height: 12),

          // Symptom chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptoms.map((s) {
              final selected = _selected.contains(s.$2);
              return FilterChip(
                label: Text('${s.$1} ${s.$2}'),
                selected: selected,
                onSelected: (v) => setState(() => v ? _selected.add(s.$2) : _selected.remove(s.$2)),
                selectedColor: AppColors.accentMuted,
                checkmarkColor: AppColors.accent,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Photo preview
          Text('Your photo', style: tt.titleLarge),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.photoPath),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: scanState.loading ? null : _analyze,
              child: scanState.loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Next → analyze'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyze() async {
    final result = await ref.read(scanProvider.notifier).diagnose(
          imageFile: File(widget.photoPath),
          symptoms: _selected.toList(),
          plantId: widget.plantId,
        );
    if (result != null && mounted) {
      context.push(AppRoutes.scanResults, extra: result.toDisplayMap());
    }
  }
}

extension on Object {
  Map<String, dynamic> toDisplayMap() => {'__scan_result__': this};
}
