import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/utils/time_utils.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  int? _productivity;
  int? _focus;
  int? _mentalTired;
  int? _physicalEnergy;
  int? _distracted;
  bool? _usedWhitelisted;
  final Set<String> _usedApps = {};
  int? _satisfaction;
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _productivity != null &&
      _focus != null &&
      _mentalTired != null &&
      _physicalEnergy != null &&
      _distracted != null &&
      _usedWhitelisted != null &&
      (_usedWhitelisted != true || _usedApps.isNotEmpty) &&
      _satisfaction != null;

  Future<void> _submit() async {
    final sessionId = ref.read(sessionControllerProvider).sessionId;
    if (sessionId == null) return;
    setState(() => _saving = true);
    await ref.read(feedbackRepositoryProvider).saveFeedback(
          sessionId: sessionId,
          qProductivity: _productivity!,
          qFocus: _focus!,
          qMentalTired: _mentalTired!,
          qPhysicalEnergy: _physicalEnergy!,
          qDistracted: _distracted!,
          qUsedWhitelisted: _usedWhitelisted!,
          qUsedApps: _usedWhitelisted == true ? _usedApps.toList() : [],
          qSatisfaction: _satisfaction!,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    ref.read(sessionControllerProvider.notifier).reset();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved. Nice work!')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final whitelist = ref.watch(whitelistProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Session Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SessionSummary(sessionState: sessionState),
            const SizedBox(height: 24),
            _RatingQuestion(
              title: 'How productive were you?',
              value: _productivity,
              onChanged: (v) => setState(() => _productivity = v),
            ),
            _RatingQuestion(
              title: 'How focused were you?',
              value: _focus,
              onChanged: (v) => setState(() => _focus = v),
            ),
            _RatingQuestion(
              title: 'How mentally tired were you?',
              lowLabel: 'Very fresh',
              highLabel: 'Very tired',
              value: _mentalTired,
              onChanged: (v) => setState(() => _mentalTired = v),
            ),
            _RatingQuestion(
              title: 'How physically energized were you?',
              lowLabel: 'Very low',
              highLabel: 'Very high',
              value: _physicalEnergy,
              onChanged: (v) => setState(() => _physicalEnergy = v),
            ),
            _RatingQuestion(
              title: 'How distracted were you?',
              lowLabel: 'Not at all',
              highLabel: 'Extremely',
              value: _distracted,
              onChanged: (v) => setState(() => _distracted = v),
            ),
            _YesNoQuestion(
              title: 'Did you use any of your whitelisted apps during this session?',
              value: _usedWhitelisted,
              onChanged: (v) => setState(() {
                _usedWhitelisted = v;
                if (v != true) _usedApps.clear();
              }),
            ),
            if (_usedWhitelisted == true) ...[
              const SizedBox(height: 8),
              Text('Which ones?', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: whitelist.map((app) {
                  return FilterChip(
                    label: Text(app.appName),
                    selected: _usedApps.contains(app.packageName),
                    onSelected: (_) {
                      setState(() {
                        if (_usedApps.contains(app.packageName)) {
                          _usedApps.remove(app.packageName);
                        } else {
                          _usedApps.add(app.packageName);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            _RatingQuestion(
              title: 'Overall satisfaction with this session',
              value: _satisfaction,
              onChanged: (v) => setState(() => _satisfaction = v),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSubmit && !_saving ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({required this.sessionState});

  final SessionControllerState sessionState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Duration: ${formatMinutes(sessionState.durationMinutes.toDouble())}'),
            Text('Ended early: ${sessionState.endedEarly ? "Yes" : "No"}'),
            Text('Blocked attempts: ${sessionState.attemptsCount}'),
          ],
        ),
      ),
    );
  }
}

class _RatingQuestion extends StatelessWidget {
  const _RatingQuestion({
    required this.title,
    required this.value,
    required this.onChanged,
    this.lowLabel,
    this.highLabel,
  });

  final String title;
  final int? value;
  final ValueChanged<int> onChanged;
  final String? lowLabel;
  final String? highLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) {
              final rating = i + 1;
              final isSelected = value == rating;
              return GestureDetector(
                onTap: () => onChanged(rating),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (lowLabel != null || highLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (lowLabel != null) Text(lowLabel!, style: Theme.of(context).textTheme.labelSmall),
                  if (highLabel != null) Text(highLabel!, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _YesNoQuestion extends StatelessWidget {
  const _YesNoQuestion({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Yes')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          // The question starts unanswered, so an empty selection is valid.
          emptySelectionAllowed: true,
          selected: value == null ? <bool>{} : {value!},
          onSelectionChanged: (s) => onChanged(s.isEmpty ? null : s.first),
        ),
      ],
    );
  }
}
