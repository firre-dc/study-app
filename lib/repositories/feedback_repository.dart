import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:study_app/database/database.dart';
import 'package:uuid/uuid.dart';

class FeedbackRepository {
  FeedbackRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<void> saveFeedback({
    required String sessionId,
    required int qProductivity,
    required int qFocus,
    required int qMentalTired,
    required int qPhysicalEnergy,
    required int qDistracted,
    required bool qUsedWhitelisted,
    List<String> qUsedApps = const [],
    required int qSatisfaction,
    String? notes,
  }) async {
    final companion = SessionFeedbacksCompanion.insert(
      id: _uuid.v4(),
      sessionId: sessionId,
      qProductivity: qProductivity,
      qFocus: qFocus,
      qMentalTired: qMentalTired,
      qPhysicalEnergy: qPhysicalEnergy,
      qDistracted: qDistracted,
      qUsedWhitelisted: Value(qUsedWhitelisted),
      qUsedAppsJson: Value(qUsedApps.isEmpty ? null : jsonEncode(qUsedApps)),
      qSatisfaction: qSatisfaction,
      notes: Value(notes),
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
