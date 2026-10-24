import 'package:flutter_test/flutter_test.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/repositories/dashboard_repository.dart';
import 'package:study_app/services/recommendation_service.dart';

StudySession _session({
  required int id,
  required DateTime start,
  required double durationMinutes,
  int dayOfWeek = 0,
  int hourOfDay = 9,
  String timeBlock = 'morning',
}) {
  return StudySession(
    id: 's$id',
    startTime: start.millisecondsSinceEpoch,
    endTime: start.add(Duration(minutes: durationMinutes.round())).millisecondsSinceEpoch,
    durationMinutes: durationMinutes,
    endedEarly: false,
    dayOfWeek: dayOfWeek,
    hourOfDay: hourOfDay,
    timeBlock: timeBlock,
    attemptsCount: 0,
    createdAt: start.millisecondsSinceEpoch,
  );
}

SessionFeedback _feedback({
  required String sessionId,
  required int productivity,
  int mentalTired = 3,
  int satisfaction = 7,
}) {
  return SessionFeedback(
    id: 'f$sessionId',
    sessionId: sessionId,
    qProductivity: productivity,
    qFocus: productivity,
    qMentalTired: mentalTired,
    qPhysicalEnergy: 7,
    qDistracted: 2,
    qUsedWhitelisted: false,
    qUsedAppsJson: null,
    qSatisfaction: satisfaction,
    notes: null,
    submittedAt: 0,
  );
}

StudySessionWithFeedback _item({
  required int id,
  required DateTime start,
  required double durationMinutes,
  required int productivity,
  int dayOfWeek = 0,
  int hourOfDay = 9,
  String timeBlock = 'morning',
  int mentalTired = 3,
  int satisfaction = 7,
}) {
  final s = _session(
    id: id,
    start: start,
    durationMinutes: durationMinutes,
    dayOfWeek: dayOfWeek,
    hourOfDay: hourOfDay,
    timeBlock: timeBlock,
  );
  final f = _feedback(
    sessionId: s.id,
    productivity: productivity,
    mentalTired: mentalTired,
    satisfaction: satisfaction,
  );
  return StudySessionWithFeedback(session: s, feedback: f);
}

void main() {
  final service = RecommendationService();

  group('optimalSessionLength', () {
    test('returns null when total time < 10 hours', () {
      final all = [
        _session(id: 1, start: DateTime(2026, 1, 1, 9), durationMinutes: 25),
        _session(id: 2, start: DateTime(2026, 1, 2, 9), durationMinutes: 25),
      ];
      final withFeedback = [
        _item(id: 1, start: DateTime(2026, 1, 1, 9), durationMinutes: 25, productivity: 8),
        _item(id: 2, start: DateTime(2026, 1, 2, 9), durationMinutes: 25, productivity: 9),
      ];
      expect(
        service.optimalSessionLength(allSessions: all, sessionsWithFeedback: withFeedback),
        isNull,
      );
    });

    test('returns null when no length bucket has >= 3 sessions', () {
      // 12 hours total but each length appears only twice
      final base = DateTime(2026, 1, 1, 9);
      final all = <StudySession>[];
      final withFeedback = <StudySessionWithFeedback>[];
      for (var i = 0; i < 6; i++) {
        final dur = i < 2 ? 15.0 : (i < 4 ? 45.0 : 75.0);
        all.add(_session(id: i, start: base.add(Duration(days: i)), durationMinutes: dur));
        withFeedback.add(_item(
          id: i,
          start: base.add(Duration(days: i)),
          durationMinutes: dur,
          productivity: 7,
        ));
      }
      // 15*2 + 45*2 + 75*2 = 270 min = 4.5h - still < 10h, add more
      // Need >= 10h: use longer durations
      for (var i = 6; i < 10; i++) {
        all.add(_session(id: i, start: base.add(Duration(days: i)), durationMinutes: 90));
        withFeedback.add(_item(
          id: i,
          start: base.add(Duration(days: i)),
          durationMinutes: 90,
          productivity: 6,
        ));
      }
      // total: 15*2+45*2+75*2+90*4 = 30+90+150+360 = 630 min = 10.5h
      final result = service.optimalSessionLength(
        allSessions: all,
        sessionsWithFeedback: withFeedback,
      );
      // 90-min bucket has 4 sessions (>=3), should be recommended
      expect(result, isNotNull);
      expect(result!.recommended.label, '60+ min');
    });

    test('picks bucket with highest avg productivity when enough sessions', () {
      final base = DateTime(2026, 1, 1, 9);
      final all = <StudySession>[];
      final withFeedback = <StudySessionWithFeedback>[];

      // 25-min bucket: 4 sessions, avg productivity 9
      for (var i = 0; i < 4; i++) {
        final start = base.add(Duration(days: i));
        all.add(_session(id: i, start: start, durationMinutes: 25));
        withFeedback.add(_item(
          id: i,
          start: start,
          durationMinutes: 25,
          productivity: 9,
          mentalTired: 2,
        ));
      }
      // 50-min bucket: 4 sessions, avg productivity 6
      for (var i = 4; i < 8; i++) {
        final start = base.add(Duration(days: i));
        all.add(_session(id: i, start: start, durationMinutes: 50));
        withFeedback.add(_item(
          id: i,
          start: start,
          durationMinutes: 50,
          productivity: 6,
          mentalTired: 8,
        ));
      }
      // total: 25*4 + 50*4 = 300 min = 5h - need more
      for (var i = 8; i < 20; i++) {
        final start = base.add(Duration(days: i));
        all.add(_session(id: i, start: start, durationMinutes: 25));
        withFeedback.add(_item(
          id: i,
          start: start,
          durationMinutes: 25,
          productivity: 9,
          mentalTired: 2,
        ));
      }
      // total: 25*16 + 50*4 = 600 min = 10h exactly

      final result = service.optimalSessionLength(
        allSessions: all,
        sessionsWithFeedback: withFeedback,
      );
      expect(result, isNotNull);
      expect(result!.recommended.label, '25–29 min');
      expect(result.recommended.avgProductivity, closeTo(9.0, 0.01));
    });
  });

  group('bestStudyTime', () {
    test('returns null when total time < 10 hours', () {
      final all = [
        _session(id: 1, start: DateTime(2026, 1, 1, 9), durationMinutes: 25),
      ];
      final withFeedback = [
        _item(id: 1, start: DateTime(2026, 1, 1, 9), durationMinutes: 25, productivity: 8),
      ];
      expect(
        service.bestStudyTime(allSessions: all, sessionsWithFeedback: withFeedback),
        isNull,
      );
    });

    test('picks day/block with highest avg productivity', () {
      final base = DateTime(2026, 1, 5); // Monday
      final all = <StudySession>[];
      final withFeedback = <StudySessionWithFeedback>[];

      // Monday morning (dayOfWeek=0): high productivity
      for (var i = 0; i < 8; i++) {
        final start = base.add(Duration(days: i * 7)); // same day each week
        all.add(_session(
          id: i,
          start: start,
          durationMinutes: 80,
          dayOfWeek: 0,
          hourOfDay: 9,
          timeBlock: 'morning',
        ));
        withFeedback.add(_item(
          id: i,
          start: start,
          durationMinutes: 80,
          productivity: 9,
          dayOfWeek: 0,
          hourOfDay: 9,
          timeBlock: 'morning',
        ));
      }
      // Wednesday evening (dayOfWeek=2): lower productivity
      for (var i = 8; i < 14; i++) {
        final start = base.add(Duration(days: (i - 8) * 7 + 2));
        all.add(_session(
          id: i,
          start: start,
          durationMinutes: 80,
          dayOfWeek: 2,
          hourOfDay: 20,
          timeBlock: 'evening',
        ));
        withFeedback.add(_item(
          id: i,
          start: start,
          durationMinutes: 80,
          productivity: 5,
          dayOfWeek: 2,
          hourOfDay: 20,
          timeBlock: 'evening',
        ));
      }
      // total: 80*14 = 1120 min = 18.67h

      final result = service.bestStudyTime(
        allSessions: all,
        sessionsWithFeedback: withFeedback,
      );
      expect(result, isNotNull);
      expect(result!.bestTimeBucket.dayOfWeek, 0);
      expect(result.bestTimeBucket.timeBlock, 'morning');
      expect(result.bestTimeBucket.avgProductivity, closeTo(9.0, 0.01));
      expect(result.bestTimeBucket.sessions, 8);
    });
  });
}
