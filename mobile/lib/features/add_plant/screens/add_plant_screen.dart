import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../add_plant_actions.dart';

/// Variation B — pick-your-method entry screen (recommended in design handoff).
class AddPlantScreen extends StatelessWidget {
  const AddPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add a plant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
        children: [
          Text('How do you want to add it?', style: tt.headlineMedium),
          const SizedBox(height: 16),
          ..._methods(context).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MethodTile(method: m),
              )),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.quiz),
              child: Text(
                'Not sure what to grow? Take the recommend quiz',
                style: tt.bodySmall?.copyWith(decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Method> _methods(BuildContext context) => [
        _Method(
          icon: '📷',
          title: 'Scan with camera',
          subtitle: 'Point at the plant — AI will identify it',
          onTap: () => context.push('${AppRoutes.scan}?mode=identify'),
        ),
        _Method(
          icon: '🔍',
          title: 'Search by name',
          subtitle: 'Browse our species catalog',
          onTap: () => context.push(AppRoutes.plantSearch),
        ),
        _Method(
          icon: '📝',
          title: 'Add manually',
          subtitle: 'Fill in the details yourself',
          onTap: () => _showManualForm(context),
        ),
        _Method(
          icon: '🪪',
          title: 'Scan plant tag',
          subtitle: 'Snap the nursery label',
          onTap: () => context.push('${AppRoutes.scan}?mode=identify'),
        ),
      ];

  void _showManualForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ManualAddSheet(),
    );
  }
}

class _Method {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Method({required this.icon, required this.title, required this.subtitle, required this.onTap});
}

class _MethodTile extends StatelessWidget {
  final _Method method;
  const _MethodTile({required this.method});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: method.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(method.icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(method.subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ManualAddSheet extends ConsumerStatefulWidget {
  const _ManualAddSheet();

  @override
  ConsumerState<_ManualAddSheet> createState() => _ManualAddSheetState();
}

class _ManualAddSheetState extends ConsumerState<_ManualAddSheet> {
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a common name.');
      return;
    }
    final species = _speciesCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    setState(() {
      _saving = true;
      _error = null;
    });

    // care_schedule is omitted so the backend applies sensible defaults
    // (water every 7 days, fertilize every 30).
    final payload = <String, dynamic>{
      'common_name': name,
      'species': species.isNotEmpty ? species : name,
      if (location.isNotEmpty) 'location': location,
    };

    final error = await addPlantFromPayload(ref, context, payload, displayName: name);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
    // On success addPlantFromPayload navigates away; nothing more to do.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 22, right: 22, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add plant manually', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Common name *')),
          const SizedBox(height: 10),
          TextField(controller: _speciesCtrl, decoration: const InputDecoration(labelText: 'Species (optional)')),
          const SizedBox(height: 10),
          TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Where does it live?')),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add plant'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
