import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/main.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/dashboard_repository.dart';
import 'package:study_app/repositories/feedback_repository.dart';
import 'package:study_app/repositories/session_repository.dart';

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository(this.session);

  final StudySession session;

  @override
  Future<List<StudySessionWithFeedback>> getSessionsWithFeedback() async =>
      const [];

  @override
  Future<int> getTotalAttempts() async => 0;

  @override
  Future<double> getTotalMinutes() async => session.durationMinutes;

  @override
  Future<List<StudySession>> getAllSessions() async => [session];
}

class _FakeSessionRepository implements SessionRepository {
  _FakeSessionRepository({required this.session, required this.attempts});

  final StudySession session;
  final List<BlockAttempt> attempts;

  @override
  Future<StudySession?> getSession(String id) async =>
      id == session.id ? session : null;

  @override
  Future<List<BlockAttempt>> getAttempts(String sessionId) async => attempts;

  @override
  Future<List<StudySession>> getAllSessions() async => [session];

  @override
  Stream<List<StudySession>> watchAllSessions() => Stream.value([session]);

  @override
  Future<StudySession> createSession({
    String? id,
    required DateTime startTime,
    required int durationMinutes,
  }) async => throw UnimplementedError();

  @override
  Future<void> endSession(
    String sessionId, {
    required bool endedEarly,
    required int? attemptsCount,
    DateTime? endedAt,
  }) async {}

  @override
  Future<void> incrementAttempts(String sessionId) async {}

  @override
  Future<void> recordAttempt({
    required String sessionId,
    required String blockedPackage,
  }) async {}
}

class _FakeFeedbackRepository implements FeedbackRepository {
  _FakeFeedbackRepository(this.feedback);

  final SessionFeedback feedback;

  @override
  Future<SessionFeedback?> getFeedbackForSession(String sessionId) async =>
      feedback;

  @override
  Future<void> saveFeedback({
    required String sessionId,
    required int qProductivity,
    required bool qDistractedByOthers,
    required bool qConsumedCaffeine,
    required bool qListenedToMusic,
  }) async {}
}

void main() {
  testWidgets('tapping a session in the dashboard opens its details', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});

    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('focusflow/blocker'), (
          call,
        ) async {
          switch (call.method) {
            case 'isUsageAccessGranted':
            case 'canDrawOverlays':
            case 'isIgnoringBatteryOptimizations':
              return true;
            case 'getActiveSession':
              return null;
            case 'consumePendingAttempts':
              return <String>[];
            default:
              return null;
          }
        });

    final start = DateTime(2026, 1, 5, 9);
    final session = StudySession(
      id: 'session-1',
      startTime: start.millisecondsSinceEpoch,
      endTime: start.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
      durationMinutes: 30,
      endedEarly: false,
      dayOfWeek: 0,
      hourOfDay: 9,
      timeBlock: 'morning',
      attemptsCount: 1,
      createdAt: start.millisecondsSinceEpoch,
    );
    final feedback = SessionFeedback(
      id: 'feedback-1',
      sessionId: session.id,
      qProductivity: 7,
      qDistractedByOthers: false,
      qConsumedCaffeine: true,
      qListenedToMusic: false,
      submittedAt: start.millisecondsSinceEpoch,
    );
    final attempts = [
      BlockAttempt(
        id: 'attempt-1',
        sessionId: session.id,
        blockedPackage: 'com.example.blocked',
        attemptTime: start
            .add(const Duration(minutes: 10))
            .millisecondsSinceEpoch,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(session),
          ),
          sessionRepositoryProvider.overrideWithValue(
            _FakeSessionRepository(session: session, attempts: attempts),
          ),
          feedbackRepositoryProvider.overrideWithValue(
            _FakeFeedbackRepository(feedback),
          ),
        ],
        child: const FocusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Session History'), findsOneWidget);

    await tester.tap(find.textContaining('30m — Mon, 09:00'));
    await tester.pumpAndSettle();

    expect(find.text('Session Details'), findsOneWidget);
    expect(find.text('Session Summary'), findsOneWidget);
    expect(find.text('Survey Answers'), findsOneWidget);
    expect(find.text('7 / 10'), findsOneWidget);
    expect(find.text('Distracted by others'), findsOneWidget);
    expect(find.text('Consumed caffeine'), findsOneWidget);
    expect(find.text('Listened to music'), findsOneWidget);
    expect(find.text('Blocked Attempts'), findsOneWidget);
    expect(find.text('com.example.blocked'), findsOneWidget);
  });
}
