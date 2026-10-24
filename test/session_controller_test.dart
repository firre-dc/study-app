import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/session_repository.dart';
import 'package:study_app/repositories/whitelist_repository.dart';

class _FakeWhitelist implements WhitelistRepository {
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

/// Simulates the drift background isolate never answering (the device bug).
class _HangingSessionRepository extends _FakeSessionRepository {
  @override
  Future<StudySession> createSession({
    String? id,
    required DateTime startTime,
    required int durationMinutes,
  }) => Completer<StudySession>().future;

  @override
  Future<void> endSession(
    String sessionId, {
    required bool endedEarly,
    required int? attemptsCount,
    DateTime? endedAt,
  }) => Completer<void>().future;
}

class _HangingWhitelist extends _FakeWhitelist {
  @override
  Future<List<AppWhitelist>> getAll() => Completer<List<AppWhitelist>>().future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startSession starts the wall-clock ticker', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('focusflow/blocker'),
      (call) async {
        switch (call.method) {
          case 'getActiveSession':
            return null;
          case 'consumePendingAttempts':
            return <String>[];
          default:
            return null;
        }
      },
    );

    final container = ProviderContainer(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(_FakeSessionRepository()),
        whitelistRepositoryProvider.overrideWithValue(_FakeWhitelist()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(sessionControllerProvider.notifier);
    await notifier.startSession();

    final started = container.read(sessionControllerProvider);
    expect(started.state, SessionState.active);
    expect(started.sessionId, isNotNull);
    expect(started.endsAt, isNotNull);

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final ticking = container.read(sessionControllerProvider);
    expect(ticking.remainingSeconds, lessThan(25 * 60));
  });

  test(
    'startSession is active immediately even if the database hangs',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('focusflow/blocker'),
        (call) async {
          switch (call.method) {
            case 'getActiveSession':
              return null;
            case 'consumePendingAttempts':
              return <String>[];
            default:
              return null;
          }
        },
      );

      final container = ProviderContainer(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(
            _HangingSessionRepository(),
          ),
          whitelistRepositoryProvider.overrideWithValue(_HangingWhitelist()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sessionControllerProvider.notifier);

      // Must return without waiting for the database or native whitelist read.
      await notifier.startSession().timeout(const Duration(seconds: 1));

      final started = container.read(sessionControllerProvider);
      expect(started.state, SessionState.active);
      expect(started.remainingSeconds, 25 * 60);
      expect(started.sessionId, isNotNull);

      // Completion must not wait for the hung database either.
      await notifier.endEarly().timeout(const Duration(seconds: 1));
      expect(
        container.read(sessionControllerProvider).state,
        SessionState.ended,
      );
    },
  );
}
