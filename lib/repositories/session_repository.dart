import 'package:drift/drift.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/utils/time_utils.dart';
import 'package:uuid/uuid.dart';

class SessionRepository {
  SessionRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<StudySession> createSession({
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final local = startTime;
    final companion = StudySessionsCompanion.insert(
      id: _uuid.v4(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      durationMinutes: durationMinutes.toDouble(),
      endedEarly: const Value(false),
      dayOfWeek: local.weekday - 1,
      hourOfDay: local.hour,
      timeBlock: TimeBlockX.fromHour(local.hour).storageValue,
      attemptsCount: const Value(0),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final inserted = await _db.into(_db.studySessions).insertReturning(companion);
    return inserted;
  }

  Future<void> endSession(
    String sessionId, {
    required bool endedEarly,
    required int attemptsCount,
  }) async {
    final actualEnd = DateTime.now();
    final session =
        await (_db.select(_db.studySessions)..where((t) => t.id.equals(sessionId)))
            .getSingleOrNull();
    if (session == null) return;
    final duration = actualEnd
        .difference(DateTime.fromMillisecondsSinceEpoch(session.startTime))
        .inSeconds /
        60.0;
    await (_db.update(_db.studySessions)..where((t) => t.id.equals(sessionId)))
        .write(StudySessionsCompanion(
      endTime: Value(actualEnd.millisecondsSinceEpoch),
      durationMinutes: Value(duration < 0.01 ? 0.01 : duration),
      endedEarly: Value(endedEarly),
      attemptsCount: Value(attemptsCount),
    ));
  }

  Future<StudySession?> getSession(String id) =>
      (_db.select(_db.studySessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<StudySession>> watchAllSessions() {
    final query = _db.select(_db.studySessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)]);
    return query.watch();
  }

  Future<List<StudySession>> getAllSessions() =>
      _db.select(_db.studySessions).get();

  Future<void> incrementAttempts(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    await (_db.update(_db.studySessions)..where((t) => t.id.equals(sessionId)))
        .write(StudySessionsCompanion(
      attemptsCount: Value(session.attemptsCount + 1),
    ));
  }

  Future<void> recordAttempt({
    required String sessionId,
    required String blockedPackage,
  }) async {
    final companion = BlockAttemptsCompanion.insert(
      id: _uuid.v4(),
      sessionId: sessionId,
      blockedPackage: blockedPackage,
      attemptTime: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.into(_db.blockAttempts).insert(companion);
    await incrementAttempts(sessionId);
  }

  Future<List<BlockAttempt>> getAttempts(String sessionId) {
    final query = _db.select(_db.blockAttempts)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.attemptTime)]);
    return query.get();
  }
}
