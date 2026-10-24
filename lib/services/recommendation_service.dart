import 'package:study_app/database/database.dart';
import 'package:study_app/repositories/dashboard_repository.dart';
import 'package:study_app/utils/time_utils.dart';

const double minHoursForRecommendations = 10.0;
const int minSessionsForTimeRecommendation = 2;
const int minSessionsForLengthRecommendation = 3;

class RecommendationService {
  /// Returns the best study time based on average productivity score.
  /// Requires total study time >= 10 hours to return a recommendation.
  /// [allSessions] must include both sessions with and without feedback.
  /// [sessionsWithFeedback] is used for computing productivity averages.
  RecommendationResult? bestStudyTime({
    required List<StudySession> allSessions,
    required List<StudySessionWithFeedback> sessionsWithFeedback,
  }) {
    final totalMinutes = allSessions.fold(0.0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    if (totalHours < minHoursForRecommendations) return null;

    final groups = <String, TimeBucket>{};
    for (final item in sessionsWithFeedback) {
      final s = item.session;
      final key = '${s.dayOfWeek}_${s.timeBlock}';
      final bucket = groups.putIfAbsent(
        key,
        () => TimeBucket(dayOfWeek: s.dayOfWeek, timeBlock: s.timeBlock),
      );
      bucket.add(item.feedback.qProductivity, s.durationMinutes);
    }

    final eligible = groups.values
        .where((b) => b.sessions >= minSessionsForTimeRecommendation)
        .toList();

    if (eligible.isEmpty) return null;

    eligible.sort((a, b) {
      final byScore = b.avgProductivity.compareTo(a.avgProductivity);
      if (byScore != 0) return byScore;
      return b.sessions.compareTo(a.sessions);
    });

    final best = eligible.first;
    return RecommendationResult(
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      bestTimeBucket: best,
      allBuckets: eligible,
    );
  }

  /// Returns the optimal session length based on average productivity vs
  /// duration buckets. Requires total study time >= 10 hours.
  DurationRecommendation? optimalSessionLength({
    required List<StudySession> allSessions,
    required List<StudySessionWithFeedback> sessionsWithFeedback,
  }) {
    final totalMinutes = allSessions.fold(0.0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    if (totalHours < minHoursForRecommendations) return null;

    final buckets = <String, LengthBucket>{};
    for (final item in sessionsWithFeedback) {
      final s = item.session;
      final bucketLabel = lengthBucketLabel(s.durationMinutes);
      final bucket = buckets.putIfAbsent(
        bucketLabel,
        () => LengthBucket(label: bucketLabel),
      );
      bucket.add(
        item.feedback.qProductivity,
        item.feedback.qMentalTired,
        item.feedback.qSatisfaction,
      );
    }

    final eligible = buckets.values
        .where((b) => b.sessions >= minSessionsForLengthRecommendation)
        .toList();

    if (eligible.isEmpty) return null;

    eligible.sort((a, b) {
      final byScore = b.avgProductivity.compareTo(a.avgProductivity);
      if (byScore != 0) return byScore;
      final byTired = a.avgMentalTired.compareTo(b.avgMentalTired);
      if (byTired != 0) return byTired;
      return b.sessions.compareTo(a.sessions);
    });

    final best = eligible.first;
    return DurationRecommendation(
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      recommended: best,
      allBuckets: eligible,
    );
  }
}

class RecommendationResult {
  RecommendationResult({
    required this.totalHours,
    required this.totalMinutes,
    required this.bestTimeBucket,
    required this.allBuckets,
  });

  final double totalHours;
  final double totalMinutes;
  final TimeBucket bestTimeBucket;
  final List<TimeBucket> allBuckets;
}

class DurationRecommendation {
  DurationRecommendation({
    required this.totalHours,
    required this.totalMinutes,
    required this.recommended,
    required this.allBuckets,
  });

  final double totalHours;
  final double totalMinutes;
  final LengthBucket recommended;
  final List<LengthBucket> allBuckets;
}

class TimeBucket {
  TimeBucket({required this.dayOfWeek, required this.timeBlock});

  final int dayOfWeek;
  final String timeBlock;

  int _count = 0;
  double _productivitySum = 0;
  double _totalMinutes = 0;

  void add(int productivity, double duration) {
    _count++;
    _productivitySum += productivity;
    _totalMinutes += duration;
  }

  int get sessions => _count;
  double get avgProductivity => _count == 0 ? 0 : _productivitySum / _count;
  double get totalMinutes => _totalMinutes;

  String get dayLabel => dayLabels[dayOfWeek % 7];
  String get blockLabel => TimeBlockX.fromStorage(timeBlock).label;
  String get display => '$dayLabel ($blockLabel)';
}

class LengthBucket {
  LengthBucket({required this.label});

  final String label;

  int _count = 0;
  double _productivitySum = 0;
  double _mentalTiredSum = 0;
  double _satisfactionSum = 0;

  void add(int productivity, int mentalTired, int satisfaction) {
    _count++;
    _productivitySum += productivity;
    _mentalTiredSum += mentalTired;
    _satisfactionSum += satisfaction;
  }

  int get sessions => _count;
  double get avgProductivity => _count == 0 ? 0 : _productivitySum / _count;
  double get avgMentalTired => _count == 0 ? 0 : _mentalTiredSum / _count;
  double get avgSatisfaction => _count == 0 ? 0 : _satisfactionSum / _count;
}

String lengthBucketLabel(double minutes) {
  if (minutes < 15) return '<15 min';
  if (minutes < 20) return '15–19 min';
  if (minutes < 25) return '20–24 min';
  if (minutes < 30) return '25–29 min';
  if (minutes < 40) return '30–39 min';
  if (minutes < 50) return '40–49 min';
  if (minutes < 60) return '50–59 min';
  return '60+ min';
}
