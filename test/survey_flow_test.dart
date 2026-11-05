import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/main.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/feedback_repository.dart';
import 'package:study_app/repositories/profile_repository.dart';
import 'package:study_app/repositories/session_repository.dart';
import 'package:study_app/repositories/whitelist_repository.dart';
import 'package:study_app/screens/session/session_screen.dart';

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;
  @override
  Stream<UserProfile?> watchProfile() => const Stream.empty();
  @override
  Future<void> upsert(UserProfilesCompanion profile) async {}
  @override
  List<int> parseStudyDays(String json) => [];
  @override
  String encodeStudyDays(List<int> days) => '[]';
}

class _FakeWhitelistRepository implements WhitelistRepository {
  @override
  Future<List<AppWhitelist>> getAll() async => [];
  @override
  Stream<List<AppWhitelist>> watchAll() => const Stream.empty();
  @override
  Future<void> add(AppWhitelistsCompanion app) async {}
  @override
  Future<void> remove(String packageName) async {}
  @override
  Future<void> replaceAll(List<AppWhitelistsCompanion> apps) async {}
}

class _FakeSessionRepository implements SessionRepository {
  StudySession? session;

  @override
  Future<StudySession> createSession({
    String? id,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final end = startTime.add(Duration(minutes: durationMinutes));
    final created = StudySession(
      id: id ?? 's1',
      startTime: startTime.millisecondsSinceEpoch,
      endTime: end.millisecondsSinceEpoch,
      durationMinutes: durationMinutes.toDouble(),
      endedEarly: false,
      dayOfWeek: startTime.weekday - 1,
      hourOfDay: startTime.hour,
      timeBlock: 'morning',
      attemptsCount: 0,
      createdAt: startTime.millisecondsSinceEpoch,
    );
    session = created;
    return created;
  }

  @override
  Future<void> endSession(
    String sessionId, {
    required bool endedEarly,
    required int? attemptsCount,
    DateTime? endedAt,
  }) async {}
  @override
  Future<StudySession?> getSession(String id) async => session;
  @override
  Future<List<StudySession>> getAllSessions() async => const [];
  @override
  Future<void> incrementAttempts(String sessionId) async {}
  @override
  Future<void> recordAttempt({
    required String sessionId,
    required String blockedPackage,
  }) async {}
  @override
  Future<List<BlockAttempt>> getAttempts(String sessionId) async => const [];
  @override
  Stream<List<StudySession>> watchAllSessions() => const Stream.empty();
}

class _FakeFeedbackRepository implements FeedbackRepository {
  bool saved = false;
  int failuresRemaining = 0;
  bool? distractedByOthers;
  bool? consumedCaffeine;
  bool? listenedToMusic;
  int? productivity;

  @override
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
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('database unavailable');
    }
    productivity = qProductivity;
    distractedByOthers = qDistracted > 5;
    consumedCaffeine = qPhysicalEnergy > 5;
    listenedToMusic = qUsedApps.contains(
      FeedbackRepository.musicAnswerMarker,
    );
    saved = true;
  }

  @override
  Future<SessionFeedback?> getFeedbackForSession(String sessionId) async => null;
}

/// Boots the app with fake repositories so the real onboarding/router/session
/// wiring is exercised.
Future<_FakeFeedbackRepository> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'onboarding_complete': true});

  // Make the survey fit on one screen so every control can be tapped.
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

  final feedback = _FakeFeedbackRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        whitelistRepositoryProvider.overrideWithValue(
          _FakeWhitelistRepository(),
        ),
        sessionRepositoryProvider.overrideWithValue(_FakeSessionRepository()),
        feedbackRepositoryProvider.overrideWithValue(feedback),
      ],
      child: const FocusFlowApp(),
    ),
  );
  await tester.pumpAndSettle();
  return feedback;
}

/// Starts and ends a session, then answers every required survey question.
Future<void> _openAnsweredSurvey(WidgetTester tester) async {
  await tester.tap(find.text('Start Session'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('End session early'));
  await tester.pumpAndSettle();

  expect(find.text('Session Feedback'), findsOneWidget);
  expect(find.text('Were you distracted by others?'), findsOneWidget);
  expect(
    find.text('Did you consume any caffeine before/during this session?'),
    findsOneWidget,
  );
  expect(find.text('Did you listen to music?'), findsOneWidget);
  expect(find.text('How productive was this session?'), findsOneWidget);

  // Answer the three yes/no questions with "No".
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('No').at(i));
    await tester.pump();
  }
  // Productivity is the only rating question.
  await tester.tap(find.text('5'));
  await tester.pump();
  await tester.ensureVisible(find.text('Save Session'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('submitting the survey returns to the home screen', (
    tester,
  ) async {
    final feedback = await _pumpApp(tester);
    await _openAnsweredSurvey(tester);

    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    expect(feedback.saved, isTrue);
    expect(feedback.productivity, 5);
    expect(feedback.distractedByOthers, isFalse);
    expect(feedback.consumedCaffeine, isFalse);
    expect(feedback.listenedToMusic, isFalse);
    expect(find.text('Ready to focus?'), findsOneWidget);
    // The active-session route must not linger below the survey, otherwise it
    // reappears when the survey returns home.
    expect(find.byType(SessionScreen), findsNothing);
    expect(find.text('Session Feedback'), findsNothing);
  });

  testWidgets('a failed save keeps the survey open so it can be retried', (
    tester,
  ) async {
    final feedback = await _pumpApp(tester);
    await _openAnsweredSurvey(tester);

    feedback.failuresRemaining = 1;
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    expect(feedback.saved, isFalse);
    expect(find.text('Session Feedback'), findsOneWidget);
    expect(
      find.text('Could not save your feedback. Please try again.'),
      findsOneWidget,
    );

    // Answers are still there, so a second tap can save successfully.
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    expect(feedback.saved, isTrue);
    expect(find.text('Ready to focus?'), findsOneWidget);
  });

  testWidgets('saving without a session never traps the user', (tester) async {
    final feedback = await _pumpApp(tester);
    await _openAnsweredSurvey(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FocusFlowApp)),
    );
    container.read(sessionControllerProvider.notifier).reset();
    await tester.pump();

    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    expect(feedback.saved, isFalse);
    expect(find.text('Ready to focus?'), findsOneWidget);
  });
}
