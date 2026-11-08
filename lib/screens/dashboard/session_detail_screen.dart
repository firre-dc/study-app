import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/utils/time_utils.dart';

final sessionDetailProvider = FutureProvider.family<SessionDetail?, String>((
  ref,
  sessionId,
) async {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final feedbackRepository = ref.watch(feedbackRepositoryProvider);

  final session = await sessionRepository.getSession(sessionId);
  if (session == null) return null;

  final results = await Future.wait([
    feedbackRepository.getFeedbackForSession(sessionId),
    sessionRepository.getAttempts(sessionId),
  ]);

  return SessionDetail(
    session: session,
    feedback: results[0] as SessionFeedback?,
    attempts: results[1] as List<BlockAttempt>,
  );
});

class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.feedback,
    required this.attempts,
  });

  final StudySession session;
  final SessionFeedback? feedback;
  final List<BlockAttempt> attempts;
}

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load this session: $error'),
          ),
        ),
        data: (detail) => detail == null
            ? const Center(child: Text('This session could not be found.'))
            : _SessionDetailBody(detail: detail),
      ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({required this.detail});

  final SessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final start = DateTime.fromMillisecondsSinceEpoch(session.startTime);
    final end = DateTime.fromMillisecondsSinceEpoch(session.endTime);
    final date = DateFormat('EEEE, MMM d, y').format(start);
    final timeRange =
        '${DateFormat.Hm().format(start)} – '
        '${DateFormat.Hm().format(end)}';
    final timeBlock = TimeBlockX.fromStorage(session.timeBlock);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionCard(
          icon: Icons.event_note,
          title: 'Session Summary',
          children: [
            _InfoRow(label: 'Date', value: date),
            _InfoRow(label: 'Time', value: timeRange),
            _InfoRow(
              label: 'Duration',
              value: formatMinutes(session.durationMinutes),
            ),
            _InfoRow(
              label: 'Time block',
              value: '${timeBlock.label} (${timeBlock.range})',
            ),
            _InfoRow(
              label: 'Ended early',
              value: session.endedEarly ? 'Yes' : 'No',
            ),
            _InfoRow(
              label: 'Blocked attempts',
              value: '${session.attemptsCount}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SurveyCard(feedback: detail.feedback),
        if (detail.attempts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AttemptsCard(attempts: detail.attempts),
        ],
      ],
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({required this.feedback});

  final SessionFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    final feedback = this.feedback;
    if (feedback == null) {
      return _SectionCard(
        icon: Icons.assignment_outlined,
        title: 'Survey Answers',
        children: [
          Text(
            'No survey feedback was recorded for this session.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return _SectionCard(
      icon: Icons.assignment_outlined,
      title: 'Survey Answers',
      children: [
        _ProductivityAnswer(value: feedback.qProductivity),
        const Divider(height: 24),
        _BooleanAnswer(
          label: 'Distracted by others',
          value: feedback.qDistractedByOthers,
        ),
        _BooleanAnswer(
          label: 'Consumed caffeine',
          value: feedback.qConsumedCaffeine,
        ),
        _BooleanAnswer(
          label: 'Listened to music',
          value: feedback.qListenedToMusic,
        ),
      ],
    );
  }
}

class _ProductivityAnswer extends StatelessWidget {
  const _ProductivityAnswer({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Productivity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text('$value / 10', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(10, (index) {
            final filled = index < value;
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index == 9 ? 0 : 4),
                decoration: BoxDecoration(
                  color: filled
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BooleanAnswer extends StatelessWidget {
  const _BooleanAnswer({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 20,
            color: value ? colorScheme.primary : colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value ? 'Yes' : 'No',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _AttemptsCard extends StatelessWidget {
  const _AttemptsCard({required this.attempts});

  final List<BlockAttempt> attempts;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.block,
      title: 'Blocked Attempts',
      children: [
        for (final attempt in attempts.reversed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    attempt.blockedPackage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat.Hm().format(
                    DateTime.fromMillisecondsSinceEpoch(attempt.attemptTime),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
