import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/recommendation_service.dart';
import 'package:study_app/utils/time_utils.dart';

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final recService = ref.watch(recommendationServiceProvider);

  final allSessions = await repo.getAllSessions();
  final withFeedback = await repo.getSessionsWithFeedback();
  final totalAttempts = await repo.getTotalAttempts();

  final bestTime = recService.bestStudyTime(
    allSessions: allSessions,
    sessionsWithFeedback: withFeedback,
  );
  final optimalLength = recService.optimalSessionLength(
    allSessions: allSessions,
    sessionsWithFeedback: withFeedback,
  );

  return DashboardData(
    totalSessions: allSessions.length,
    totalMinutes: allSessions.fold(0.0, (sum, s) => sum + s.durationMinutes),
    totalAttempts: totalAttempts,
    bestTime: bestTime,
    optimalLength: optimalLength,
    sessions: allSessions,
  );
});

class DashboardData {
  DashboardData({
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalAttempts,
    required this.bestTime,
    required this.optimalLength,
    required this.sessions,
  });

  final int totalSessions;
  final double totalMinutes;
  final int totalAttempts;
  final RecommendationResult? bestTime;
  final DurationRecommendation? optimalLength;
  final List<StudySession> sessions;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.totalMinutes / 60.0 / minHoursForRecommendations).clamp(0.0, 1.0);
    final hasRecommendations = data.bestTime != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _StatsRow(data: data),
        const SizedBox(height: 24),
        if (!hasRecommendations) ...[
          _InsufficientDataCard(
            totalHours: data.totalMinutes / 60.0,
            neededHours: minHoursForRecommendations,
            progress: progress,
          ),
        ] else ...[
          if (data.bestTime != null) _BestTimeCard(data: data.bestTime!),
          const SizedBox(height: 16),
          if (data.optimalLength != null)
            _OptimalLengthCard(data: data.optimalLength!)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Session lengths are too varied to determine an optimal length yet. '
                  'Complete a few more sessions of similar length for a better recommendation.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        Text('Session History', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (data.sessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No sessions yet. Complete your first study session to start building insights.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...data.sessions.map((s) => _SessionTile(session: s)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer,
            label: 'Total Study Time',
            value: formatMinutes(data.totalMinutes),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            label: 'Sessions',
            value: '${data.totalSessions}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.block,
            label: 'Blocked Attempts',
            value: '${data.totalAttempts}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InsufficientDataCard extends StatelessWidget {
  const _InsufficientDataCard({
    required this.totalHours,
    required this.neededHours,
    required this.progress,
  });

  final double totalHours;
  final double neededHours;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = (neededHours - totalHours).clamp(0.0, neededHours);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_bottom, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Building your profile...', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Need ${remaining.toStringAsFixed(1)} more hours of study sessions '
              'to generate recommendations.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Currently: ${totalHours.toStringAsFixed(1)}h / ${neededHours.toStringAsFixed(0)}h',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestTimeCard extends StatelessWidget {
  const _BestTimeCard({required this.data});

  final RecommendationResult data;

  @override
  Widget build(BuildContext context) {
    final best = data.bestTimeBucket;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Your Best Study Time', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(best.display, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Avg productivity: ${best.avgProductivity.toStringAsFixed(1)} / 10'),
            Text('${best.sessions} sessions in this block'),
            Text(formatMinutes(best.totalMinutes)),
            const SizedBox(height: 12),
            if (data.allBuckets.length > 1) ...[
              Text('Other good times:', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              ...data.allBuckets.skip(1).take(3).map(
                    (b) => Text(
                      '• ${b.display} — avg ${b.avgProductivity.toStringAsFixed(1)} (${b.sessions} sessions)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptimalLengthCard extends StatelessWidget {
  const _OptimalLengthCard({required this.data});

  final DurationRecommendation data;

  @override
  Widget build(BuildContext context) {
    final best = data.recommended;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Optimal Session Length', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(best.label, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Avg productivity: ${best.avgProductivity.toStringAsFixed(1)} / 10'),
            Text('Avg satisfaction: ${best.avgSatisfaction.toStringAsFixed(1)} / 10'),
            Text('Based on ${best.sessions} sessions'),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.fromMillisecondsSinceEpoch(session.startTime);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${formatMinutes(session.durationMinutes)} — ${dayLabel(session.dayOfWeek)}, '
            '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'),
        subtitle: Text(
          'Time block: ${TimeBlockX.fromStorage(session.timeBlock).label}'
          '${session.endedEarly ? " · Ended early" : ""}'
          '${session.attemptsCount > 0 ? " · ${session.attemptsCount} blocked attempts" : ""}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
