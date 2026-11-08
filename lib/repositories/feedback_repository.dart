import 'package:study_app/database/database.dart';
import 'package:uuid/uuid.dart';

class FeedbackRepository {
  FeedbackRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<void> saveFeedback({
    required String sessionId,
    required int qProductivity,
    required bool qDistractedByOthers,
    required bool qConsumedCaffeine,
    required bool qListenedToMusic,
  }) async {
    final companion = SessionFeedbacksCompanion.insert(
      id: _uuid.v4(),
      sessionId: sessionId,
      qProductivity: qProductivity,
      qDistractedByOthers: qDistractedByOthers,
      qConsumedCaffeine: qConsumedCaffeine,
      qListenedToMusic: qListenedToMusic,
      submittedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.into(_db.sessionFeedbacks).insert(companion);
  }

  Future<SessionFeedback?> getFeedbackForSession(String sessionId) {
    final query = _db.select(_db.sessionFeedbacks)
      ..where((t) => t.sessionId.equals(sessionId));
    return query.getSingleOrNull();
  }
}
