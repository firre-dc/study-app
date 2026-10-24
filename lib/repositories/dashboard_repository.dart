import 'package:drift/drift.dart';
import 'package:study_app/database/database.dart';

class DashboardRepository {
  DashboardRepository(this._db);
  final AppDatabase _db;

  Future<List<StudySessionWithFeedback>> getSessionsWithFeedback() async {
    final query = _db.select(_db.studySessions).join([
      innerJoin(
        _db.sessionFeedbacks,
        _db.sessionFeedbacks.sessionId.equalsExp(_db.studySessions.id),
      ),
    ]);
    final rows = await query.get();
    return rows.map((row) {
      final session = row.readTable(_db.studySessions);
      final feedback = row.readTable(_db.sessionFeedbacks);
      return StudySessionWithFeedback(session: session, feedback: feedback);
    }).toList();
  }

  Future<int> getTotalAttempts() async {
    final count = _db.blockAttempts.id.count();
    final query = _db.selectOnly(_db.blockAttempts)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<double> getTotalMinutes() async {
    final sessions = await _db.select(_db.studySessions).get();
    return sessions.fold<double>(0.0, (sum, s) => sum + s.durationMinutes);
  }

  Future<List<StudySession>> getAllSessions() =>
      _db.select(_db.studySessions).get();
}

class StudySessionWithFeedback {
  StudySessionWithFeedback({required this.session, required this.feedback});
  final StudySession session;
  final SessionFeedback feedback;
}
