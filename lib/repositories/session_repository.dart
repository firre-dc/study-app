import 'package:drift/drift.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/utils/time_utils.dart';
import 'package:uuid/uuid.dart';

class SessionRepository {
  SessionRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<StudySession> createSession({
    String? id,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final local = startTime;
    final companion = StudySessionsCompanion.insert(
      // The caller may generate the id so it can enter the active state
      // before the database write completes. Re-inserting the same id is
      // safe, which lets a failed/interrupted write be retried.
      id: id ?? _uuid.v4(),
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
    // Ignore (instead of replace) on retry: if a previous attempt already
    // wrote the row, keep its start time and attempt count intact.
    await _db
        .into(_db.studySessions)
        .insert(companion, mode: InsertMode.insertOrIgnore);
    final inserted = await getSession(companion.id.value);
    return inserted!;
  }

  Future<void> endSession(
    String sessionId, {
    required bool endedEarly,
    required int? attemptsCount,
    DateTime? endedAt,
  }) async {
    final actualEnd = endedAt ?? DateTime.now();
    final session = await (_db.select(
      _db.studySessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return;
    final duration =
        actualEnd
            .difference(DateTime.fromMillisecondsSinceEpoch(session.startTime))
            .inSeconds /
        60.0;
    await (_db.update(
      _db.studySessions,
    )..where((t) => t.id.equals(sessionId))).write(
      StudySessionsCompanion(
        endTime: Value(actualEnd.millisecondsSinceEpoch),
        durationMinutes: Value(duration < 0.01 ? 0.01 : duration),
        endedEarly: Value(endedEarly),
        // Null means the in-memory count is unknown (e.g. a session restored
        // without a database read); leave the stored count untouched.
        attemptsCount: attemptsCount == null
            ? const Value.absent()
            : Value(attemptsCount),
      ),
    );
  }

  Future<StudySession?> getSession(String id) => (_db.select(
    _db.studySessions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

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
    await (_db.update(
      _db.studySessions,
    )..where((t) => t.id.equals(sessionId))).write(
      StudySessionsCompanion(attemptsCount: Value(session.attemptsCount + 1)),
    );
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
