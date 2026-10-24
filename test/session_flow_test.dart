import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/main.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/profile_repository.dart';
import 'package:study_app/repositories/session_repository.dart';
import 'package:study_app/repositories/whitelist_repository.dart';

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

void main() {
  testWidgets('start session enters active state and counts down', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});

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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
          whitelistRepositoryProvider.overrideWithValue(
            _FakeWhitelistRepository(),
          ),
          sessionRepositoryProvider.overrideWithValue(_FakeSessionRepository()),
        ],
        child: const FocusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start Session'), findsOneWidget);
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    expect(find.text('Starting...'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FocusFlowApp)),
    );
    final state = container.read(sessionControllerProvider);
    expect(state.state, SessionState.active);
    expect(state.remainingSeconds, 25 * 60);

    // The countdown is derived from the wall clock. Let real time pass, then
    // fire the fake periodic timer so it recomputes the remaining time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(
      container.read(sessionControllerProvider).remainingSeconds,
      lessThan(1500),
    );
  });
}
