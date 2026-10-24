import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/blocker_platform.dart';

enum SessionState { idle, active, ended }

class SessionControllerState {
  const SessionControllerState({
    required this.state,
    required this.durationMinutes,
    this.sessionId,
    this.remainingSeconds = 0,
    this.endedEarly = false,
    this.attemptsCount = 0,
  });

  final SessionState state;
  final int durationMinutes;
  final String? sessionId;
  final int remainingSeconds;
  final bool endedEarly;
  final int attemptsCount;

  SessionControllerState copyWith({
    SessionState? state,
    int? durationMinutes,
    String? sessionId,
    int? remainingSeconds,
    bool? endedEarly,
    int? attemptsCount,
  }) {
    return SessionControllerState(
      state: state ?? this.state,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionId: sessionId ?? this.sessionId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      endedEarly: endedEarly ?? this.endedEarly,
      attemptsCount: attemptsCount ?? this.attemptsCount,
    );
  }
}

class SessionController extends Notifier<SessionControllerState> {
  Timer? _timer;
  int _ticksSinceAttemptsSync = 0;

  @override
  SessionControllerState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SessionControllerState(
      state: SessionState.idle,
      durationMinutes: 25,
    );
  }

  void setDurationMinutes(int minutes) {
    state = state.copyWith(durationMinutes: minutes);
  }

  Future<void> startSession() async {
    final repo = ref.read(sessionRepositoryProvider);
    final whitelist = await ref.read(whitelistRepositoryProvider).getAll();
    final packageNames = whitelist.map((w) => w.packageName).toList();

    final now = DateTime.now();
    final session = await repo.createSession(
      startTime: now,
      durationMinutes: state.durationMinutes,
    );

    await BlockerPlatform.startSession(
      sessionId: session.id,
      endTime: DateTime.fromMillisecondsSinceEpoch(session.endTime),
      totalSeconds: state.durationMinutes * 60,
      whitelist: packageNames,
    );

    state = state.copyWith(
      state: SessionState.active,
      sessionId: session.id,
      remainingSeconds: state.durationMinutes * 60,
      endedEarly: false,
      attemptsCount: 0,
    );

    BlockerPlatform.setExternalSessionEndHandler(_onExternalSessionEnd);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _onTick() {
    final remaining = state.remainingSeconds - 1;
    if (remaining <= 0) {
      _completeSession(endedEarly: false);
      return;
    }
    state = state.copyWith(remainingSeconds: remaining);

    _ticksSinceAttemptsSync++;
    if (_ticksSinceAttemptsSync >= 5) {
      _ticksSinceAttemptsSync = 0;
      _syncAttemptsFromBlocker();
    }
  }

  /// Picks up the block attempts recorded natively by the blocker service
  /// and persists them (block_attempts rows + attempts_count).
  Future<void> _syncAttemptsFromBlocker() async {
    final sessionId = state.sessionId;
    if (sessionId == null ||
        (state.state != SessionState.active)) {
      return;
    }
    final blockedPackages = await BlockerPlatform.consumePendingAttempts();
    if (blockedPackages.isEmpty || state.sessionId != sessionId) {
      return;
    }
    final repo = ref.read(sessionRepositoryProvider);
    for (final pkg in blockedPackages) {
      await repo.recordAttempt(sessionId: sessionId, blockedPackage: pkg);
    }
    state = state.copyWith(
      attemptsCount: state.attemptsCount + blockedPackages.length,
    );
  }

  void _onExternalSessionEnd() {
    if (state.state != SessionState.active) return;
    _completeSession(endedEarly: true);
  }

  Future<void> endEarly() async {
    await _completeSession(endedEarly: true);
  }

  Future<void> _completeSession({required bool endedEarly}) async {
    if (state.state != SessionState.active) return;
    _timer?.cancel();
    _timer = null;

    final sessionId = state.sessionId;
    if (sessionId == null) {
      BlockerPlatform.setExternalSessionEndHandler(null);
      state = SessionControllerState(
        state: SessionState.idle,
        durationMinutes: state.durationMinutes,
      );
      return;
    }

    // Persist any attempts recorded by the native blocker before saving.
    await _syncAttemptsFromBlocker();

    await BlockerPlatform.endSession();
    BlockerPlatform.setExternalSessionEndHandler(null);

    final repo = ref.read(sessionRepositoryProvider);
    await repo.endSession(
      sessionId,
      endedEarly: endedEarly,
      attemptsCount: state.attemptsCount,
    );

    state = state.copyWith(
      state: SessionState.ended,
      endedEarly: endedEarly,
      remainingSeconds: 0,
    );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    BlockerPlatform.setExternalSessionEndHandler(null);
    state = SessionControllerState(
      state: SessionState.idle,
      durationMinutes: state.durationMinutes,
    );
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionControllerState>(
        SessionController.new);
