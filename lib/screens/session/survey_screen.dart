import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/feedback_repository.dart';
import 'package:study_app/utils/time_utils.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  bool? _distractedByOthers;
  bool? _consumedCaffeine;
  bool? _listenedToMusic;
  int? _productivity;
  bool _saving = false;

  bool get _canSubmit =>
      _distractedByOthers != null &&
      _consumedCaffeine != null &&
      _listenedToMusic != null &&
      _productivity != null;

  Future<void> _submit() async {
    // The button is disabled while saving, but guard here too so a double
    // tap can never write two feedback rows.
    if (_saving || !_canSubmit) return;

    final sessionController = ref.read(sessionControllerProvider.notifier);
    final sessionId = ref.read(sessionControllerProvider).sessionId;
    if (sessionId == null) {
      // There is no session left to attach feedback to. Never trap the user
      // on this screen because of a stale/cleared controller state.
      if (mounted) context.go('/');
      return;
    }

    final feedbackRepository = ref.read(feedbackRepositoryProvider);

    setState(() => _saving = true);
    try {
      // The survey stores the yes/no answers through the existing feedback
      // fields; the repository also copies them to their dedicated columns.
      await feedbackRepository.saveFeedback(
        sessionId: sessionId,
        qProductivity: _productivity!,
        qFocus: _productivity!,
        qMentalTired: 5,
        qPhysicalEnergy: _consumedCaffeine! ? 10 : 1,
        qDistracted: _distractedByOthers! ? 10 : 1,
        qUsedWhitelisted: false,
        qUsedApps: _listenedToMusic!
            ? const [FeedbackRepository.musicAnswerMarker]
            : const [],
        qSatisfaction: _productivity!,
      );
    } catch (_) {
      // Keep the answers on screen so the user can retry instead of leaving
      // them with a button that spins forever.
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your feedback. Please try again.'),
        ),
      );
      return;
    }

    // Capture the controller before the await above, so a route change
    // during saving can never make this a read from a disposed widget.
    sessionController.reset();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved. Nice work!')),
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Session Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SessionSummary(sessionState: sessionState),
            const SizedBox(height: 24),
            _YesNoQuestion(
              title: 'Were you distracted by others?',
              value: _distractedByOthers,
              onChanged: (v) => setState(() => _distractedByOthers = v),
            ),
            const SizedBox(height: 24),
            _YesNoQuestion(
              title:
                  'Did you consume any caffeine before/during this session?',
              value: _consumedCaffeine,
              onChanged: (v) => setState(() => _consumedCaffeine = v),
            ),
            const SizedBox(height: 24),
            _YesNoQuestion(
              title: 'Did you listen to music?',
              value: _listenedToMusic,
              onChanged: (v) => setState(() => _listenedToMusic = v),
            ),
            const SizedBox(height: 24),
            _RatingQuestion(
              title: 'How productive was this session?',
              lowLabel: 'Not at all productive',
              highLabel: 'Extremely productive',
              value: _productivity,
              onChanged: (v) => setState(() => _productivity = v),
            ),
            const SizedBox(height: 8),
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
