import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/blocker_platform.dart';
import 'package:uuid/uuid.dart';

enum SessionState { idle, active, ended }

/// How an active session measures time.
///
/// [countdown] runs against a fixed end time. [stopwatch] is open-ended and
/// counts up until the user explicitly finishes it.
enum SessionMode { countdown, stopwatch }

/// Result of looking up a session left behind by a previous app process.
enum SessionRestoreResult { none, active, ended }

class SessionControllerState {
  const SessionControllerState({
    required this.state,
    required this.durationMinutes,
    this.mode = SessionMode.countdown,
    this.sessionId,
    this.remainingSeconds = 0,
    this.elapsedSeconds = 0,
    this.endedEarly = false,
    this.attemptsCount = 0,
    this.startedAt,
    this.endsAt,
  });

  final SessionState state;
  final int durationMinutes;
  final SessionMode mode;
  final String? sessionId;
  final int remainingSeconds;

  /// Seconds elapsed in a stopwatch session.
  final int elapsedSeconds;
  final bool endedEarly;
  final int attemptsCount;

  /// Wall-clock moment the session started.
  ///
  /// Stopwatch elapsed time is derived from this (just like the countdown is
  /// derived from [endsAt]) so a frozen Flutter process cannot slow the clock.
  final DateTime? startedAt;

  /// Wall-clock moment the session is scheduled to end.
  ///
  /// The countdown is derived from this instead of merely decrementing a
  /// counter once per timer tick, so a frozen/suspended Flutter process
  /// (battery saver, Doze, OEM power management) cannot stretch the session
  /// or make the UI disagree with the native service.
  ///
  /// Always null for [SessionMode.stopwatch].
  final DateTime? endsAt;

  bool get isStopwatch => mode == SessionMode.stopwatch;

  SessionControllerState copyWith({
    SessionState? state,
    int? durationMinutes,
    SessionMode? mode,
    String? sessionId,
    int? remainingSeconds,
    int? elapsedSeconds,
    bool? endedEarly,
    int? attemptsCount,
    DateTime? startedAt,
    DateTime? endsAt,
  }) {
    return SessionControllerState(
      state: state ?? this.state,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      mode: mode ?? this.mode,
      sessionId: sessionId ?? this.sessionId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      endedEarly: endedEarly ?? this.endedEarly,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }
}

class SessionController extends Notifier<SessionControllerState> {
  static const _uuid = Uuid();

  Timer? _timer;
  AppLifecycleListener? _lifecycleListener;
  int _ticksSinceAttemptsSync = 0;
  bool _restoring = false;
  bool _completing = false;
  bool _starting = false;

  /// Metadata for the session whose database row may not have been written
  /// yet. Keeping it here lets us retry persistence later (on resume or when
  /// the session finishes) without blocking the countdown.
  String? _pendingSessionId;
  DateTime? _pendingStartTime;
  int? _pendingDurationMinutes;
  bool _sessionPersisted = false;
  bool _attemptsKnown = true;

  @override
  SessionControllerState build() {
    _pendingSessionId = null;
    _pendingStartTime = null;
    _pendingDurationMinutes = null;
    _sessionPersisted = false;
    _attemptsKnown = true;
    _lifecycleListener?.dispose();
    _lifecycleListener = AppLifecycleListener(onResume: _onAppResumed);
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
      _lifecycleListener?.dispose();
      _lifecycleListener = null;
    });
    return const SessionControllerState(
      state: SessionState.idle,
      durationMinutes: 25,
    );
  }

  void setDurationMinutes(int minutes) {
    state = state.copyWith(durationMinutes: minutes);
  }

  /// Switches between timer and stopwatch mode on the home screen.
  ///
  /// Mode is fixed while a session is active: changing it mid-session would
  /// make the displayed clock disagree with the native blocker.
  void setMode(SessionMode mode) {
    if (state.state == SessionState.active) return;
    state = state.copyWith(mode: mode);
  }

  Future<void> startSession() async {
    if (_starting || state.state == SessionState.active) return;
    _starting = true;

    try {
      final mode = state.mode;
      final isStopwatch = mode == SessionMode.stopwatch;
      final durationMinutes = math.max(1, state.durationMinutes);
      final startTime = DateTime.now();
      final endsAt = isStopwatch
          ? null
          : startTime.add(Duration(minutes: durationMinutes));
      final sessionId = _uuid.v4();

      _pendingSessionId = sessionId;
      _pendingStartTime = startTime;
      // A stopwatch has no planned duration; the final row gets its real
      // duration when the session ends. Inserting zero keeps the row valid
      // until then and the repository's insert-or-ignore retry semantics.
      _pendingDurationMinutes = isStopwatch ? 0 : durationMinutes;
      _sessionPersisted = false;
      _attemptsKnown = true;
      _ticksSinceAttemptsSync = 0;

      // Enter the active state before touching the database or the platform
      // channel. A slow/broken SQLite isolate or a stuck native call must
      // never leave the user staring at "Starting..." forever.
      state = SessionControllerState(
        state: SessionState.active,
        mode: mode,
        durationMinutes: durationMinutes,
        sessionId: sessionId,
        remainingSeconds: isStopwatch ? 0 : durationMinutes * 60,
        endsAt: endsAt,
        startedAt: startTime,
        endedEarly: false,
        attemptsCount: 0,
      );
      BlockerPlatform.setExternalSessionEndHandler(_onExternalSessionEnd);
      _startTicker();

      // Persistence and native arming happen in the background; both are
      // retried on resume, and completion ensures the row is written.
      unawaited(_persistSession());
      // Ask for notification permission while the activity is foregrounded so
      // the completion alert can be shown at the end of the session.
      unawaited(BlockerPlatform.requestNotificationPermission());
      // This is a brand-new session id, so there is no prior external-end
      // state to check; arm the service immediately.
      unawaited(_ensureNativeSessionRunning(checkExternal: false));
    } finally {
      _starting = false;
    }
  }

  /// Writes the session row if it has not been persisted yet.
  ///
  /// Re-inserting with the same id is safe: the repository ignores conflicts,
  /// so a retry can never create a duplicate session or overwrite its data.
  Future<void> _persistSession({
    String? sessionId,
    DateTime? startTime,
    int? durationMinutes,
  }) async {
    final id = sessionId ?? _pendingSessionId;
    final start = startTime ?? _pendingStartTime;
    final duration = durationMinutes ?? _pendingDurationMinutes;
    if (id == null || start == null || duration == null) return;
    if (_sessionPersisted && _pendingSessionId == id) return;

    try {
      await ref
          .read(sessionRepositoryProvider)
          .createSession(id: id, startTime: start, durationMinutes: duration);
      if (_pendingSessionId == id) _sessionPersisted = true;
    } catch (_) {
      if (_pendingSessionId == id) _sessionPersisted = false;
    }
  }

  /// Re-attaches to a session that is still running natively.
  ///
  /// Battery savers and OEM task killers can remove the Flutter process while
  /// the foreground service (and therefore the session) is still alive. On the
  /// next launch this rebuilds the in-memory state from the native session and
  /// resumes the countdown. If the session expired while the app was gone, it
  /// is finalized normally so the user still gets the feedback screen.
  Future<SessionRestoreResult> restoreActiveSession() async {
    if (state.state == SessionState.active) {
      return SessionRestoreResult.active;
    }
    if (_restoring) return SessionRestoreResult.none;
    _restoring = true;
    try {
      final native = await BlockerPlatform.getActiveSession();
      // "active" is false only when the native service finished normally or
      // the Dart side already ended the session. The exception is a session
      // ended from the blocking overlay: it is kept around so it can still be
      // finalized (and surveyed) after an app restart.
      if (native == null ||
          native.sessionId == null ||
          (!native.active && !native.endedExternally)) {
        return SessionRestoreResult.none;
      }

      final sessionId = native.sessionId!;
      final isStopwatch = native.stopwatch;
      final totalSeconds = native.totalSeconds;
      final durationMinutes = totalSeconds > 0
          ? math.max(1, (totalSeconds / 60).round())
          : 25;

      var startTime = native.startedAt;
      DateTime? endsAt = native.endsAt;
      var elapsedSeconds = 0;
      int remaining = 0;

      if (isStopwatch) {
        // The native session stores the wall-clock start time. Stopwatch
        // elapsed time is derived from it, so the clock stays correct even
        // though Flutter was gone.
        startTime ??= await _lookupSessionStartTime(sessionId);
        startTime ??= DateTime.now();
        elapsedSeconds = _secondsElapsed(startTime);
      } else {
        // Rebuild the countdown from the native end time without waiting for
        // SQLite. The database may be slow or temporarily unavailable; that
        // must not keep the user on the home-screen spinner.
        if (endsAt == null) {
          try {
            final record = await ref
                .read(sessionRepositoryProvider)
                .getSession(sessionId)
                .timeout(const Duration(seconds: 3));
            if (record != null) {
              endsAt = DateTime.fromMillisecondsSinceEpoch(record.endTime);
              startTime ??= DateTime.fromMillisecondsSinceEpoch(
                record.startTime,
              );
            }
          } catch (_) {
            // Fall through to the safe end-time check below.
          }
        }
        if (endsAt == null) {
          await BlockerPlatform.endSession();
          return SessionRestoreResult.none;
        }

        final effectiveTotalSeconds = totalSeconds > 0
            ? totalSeconds
            : durationMinutes * 60;
        remaining = _secondsRemaining(endsAt).clamp(0, effectiveTotalSeconds);
        startTime ??= endsAt.subtract(Duration(minutes: durationMinutes));
      }

      final sessionStart = startTime;
      final plannedDuration = isStopwatch ? 0 : durationMinutes;
      _pendingSessionId = sessionId;
      _pendingStartTime = sessionStart;
      _pendingDurationMinutes = plannedDuration;
      _sessionPersisted = false;
      _attemptsKnown = false;

      state = SessionControllerState(
        state: SessionState.active,
        mode: isStopwatch ? SessionMode.stopwatch : SessionMode.countdown,
        durationMinutes: durationMinutes,
        sessionId: sessionId,
        remainingSeconds: isStopwatch ? 0 : remaining,
        elapsedSeconds: elapsedSeconds,
        startedAt: sessionStart,
        endsAt: isStopwatch ? null : endsAt,
        attemptsCount: 0,
      );
      BlockerPlatform.setExternalSessionEndHandler(_onExternalSessionEnd);

      if (native.endedExternally) {
        // Finishing a stopwatch is the normal way to end it, not "early".
        await _completeSession(endedEarly: !isStopwatch);
        return SessionRestoreResult.ended;
      }
      if (!isStopwatch && remaining <= 0) {
        await _completeSession(endedEarly: false);
        return SessionRestoreResult.ended;
      }

      _ticksSinceAttemptsSync = 0;
      _startTicker();

      // Enrich attempts / make sure the row exists in the background.
      unawaited(
        _loadRestoredRecord(
          sessionId: sessionId,
          startTime: sessionStart,
          durationMinutes: plannedDuration,
        ),
      );
      unawaited(_ensureNativeSessionRunning());
      return SessionRestoreResult.active;
    } finally {
      _restoring = false;
    }
  }

  /// Reads the persisted start time for a native session that predates the
  /// `startTimeMillis` field (or could not provide it).
  Future<DateTime?> _lookupSessionStartTime(String sessionId) async {
    try {
      final record = await ref
          .read(sessionRepositoryProvider)
          .getSession(sessionId)
          .timeout(const Duration(seconds: 3));
      if (record == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(record.startTime);
    } catch (_) {
      return null;
    }
  }

  /// Loads database-only details of a restored session without blocking the
  /// countdown. If the row is missing (for example because the process died
  /// before the initial write completed), it is recreated from the native
  /// session data so the session is not lost from history.
  Future<void> _loadRestoredRecord({
    required String sessionId,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final repo = ref.read(sessionRepositoryProvider);
    try {
      final record = await repo
          .getSession(sessionId)
          .timeout(const Duration(seconds: 5));
      if (record != null) {
        if (_pendingSessionId == sessionId) {
          _sessionPersisted = true;
          _attemptsKnown = true;
        }
        if (state.sessionId == sessionId &&
            state.state == SessionState.active &&
            state.attemptsCount != record.attemptsCount) {
          state = state.copyWith(attemptsCount: record.attemptsCount);
        }
        return;
      }
    } catch (_) {
      // Database unavailable; the native session keeps running and we retry
      // persistence when the session ends.
      return;
    }

    await _persistSession(
      sessionId: sessionId,
      startTime: startTime,
      durationMinutes: durationMinutes,
    );
    if (_pendingSessionId == sessionId && _sessionPersisted) {
      _attemptsKnown = true;
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    if (state.state != SessionState.active) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    if (state.isStopwatch) {
      final startedAt = state.startedAt;
      if (startedAt != null) {
        final elapsed = _secondsElapsed(startedAt);
        if (elapsed != state.elapsedSeconds) {
          state = state.copyWith(elapsedSeconds: elapsed);
        }
      }
      _syncAttemptsOnTick();
      return;
    }

    final endsAt = state.endsAt;
    if (endsAt != null) {
      final remaining = _secondsRemaining(endsAt);
      if (remaining <= 0) {
        _completeSession(endedEarly: false);
        return;
      }
      if (remaining != state.remainingSeconds) {
        state = state.copyWith(remainingSeconds: remaining);
      }
    } else {
      // Fallback for a state created without an end time.
      final remaining = state.remainingSeconds - 1;
      if (remaining <= 0) {
        _completeSession(endedEarly: false);
        return;
      }
      state = state.copyWith(remainingSeconds: remaining);
    }

    _syncAttemptsOnTick();
  }

  void _syncAttemptsOnTick() {
    _ticksSinceAttemptsSync++;
    if (_ticksSinceAttemptsSync >= 5) {
      _ticksSinceAttemptsSync = 0;
      _syncAttemptsFromBlocker();
    }
  }

  /// Seconds left according to the wall clock, rounded up so the display never
  /// skips a second.
  int _secondsRemaining(DateTime endsAt) {
    final millis = endsAt.difference(DateTime.now()).inMilliseconds;
    if (millis <= 0) return 0;
    return (millis / 1000).ceil();
  }

  /// Seconds elapsed according to the wall clock, rounded down like a normal
  /// stopwatch.
  int _secondsElapsed(DateTime startedAt) {
    final millis = DateTime.now().difference(startedAt).inMilliseconds;
    if (millis <= 0) return 0;
    return millis ~/ 1000;
  }

  /// Called when the app comes back to the foreground. A session may have
  /// expired or been ended natively while Flutter was frozen, and the timer
  /// may have missed ticks entirely.
  Future<void> _onAppResumed() async {
    if (state.state != SessionState.active || _restoring || _completing) return;

    if (!_sessionPersisted) {
      unawaited(_persistSession());
    }

    await _syncAttemptsFromBlocker();
    if (state.state != SessionState.active) return;

    _refreshTimer();
    if (state.state != SessionState.active) return;

    await _ensureNativeSessionRunning();
  }

  void _refreshTimer() {
    if (state.isStopwatch) {
      final startedAt = state.startedAt;
      if (startedAt == null) return;
      final elapsed = _secondsElapsed(startedAt);
      if (elapsed != state.elapsedSeconds) {
        state = state.copyWith(elapsedSeconds: elapsed);
      }
      return;
    }

    final endsAt = state.endsAt;
    if (endsAt == null) return;
    final remaining = _secondsRemaining(endsAt);
    if (remaining <= 0) {
      _completeSession(endedEarly: false);
      return;
    }
    if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  /// Re-arms the foreground service if the system stopped it (for example
  /// aggressive battery savers) while the session is still supposed to run.
  /// Starting the same session again is idempotent natively.
  Future<void> _ensureNativeSessionRunning({bool checkExternal = true}) async {
    final sessionId = state.sessionId;
    final isStopwatch = state.isStopwatch;
    final endsAt = state.endsAt;
    if (_completing ||
        state.state != SessionState.active ||
        sessionId == null ||
        (!isStopwatch && endsAt == null)) {
      return;
    }

    try {
      if (checkExternal) {
        final native = await BlockerPlatform.getActiveSession();
        if (!ref.mounted) return;
        if (_completing ||
            state.state != SessionState.active ||
            state.sessionId != sessionId) {
          return;
        }

        if (native != null &&
            native.endedExternally &&
            native.sessionId == sessionId) {
          await _completeSession(endedEarly: !isStopwatch);
          return;
        }
      }

      if (!isStopwatch && !endsAt!.isAfter(DateTime.now())) {
        await _completeSession(endedEarly: false);
        return;
      }

      final whitelist = await ref.read(whitelistRepositoryProvider).getAll();
      if (!ref.mounted) return;
      if (_completing ||
          state.state != SessionState.active ||
          state.sessionId != sessionId) {
        return;
      }
      await BlockerPlatform.startSession(
        sessionId: sessionId,
        endTime: isStopwatch ? null : endsAt,
        totalSeconds: isStopwatch ? 0 : state.durationMinutes * 60,
        whitelist: whitelist.map((w) => w.packageName).toList(),
        stopwatch: isStopwatch,
      );
    } catch (_) {
      // Best effort. The countdown already runs, and the next resume (or a
      // later tick) will try to arm the foreground service again.
    }
  }

  /// Picks up the block attempts recorded natively by the blocker service
  /// and persists them (block_attempts rows + attempts_count).
  Future<void> _syncAttemptsFromBlocker() async {
    final sessionId = state.sessionId;
    if (sessionId == null || (state.state != SessionState.active)) {
      return;
    }
    final blockedPackages = await BlockerPlatform.consumePendingAttempts();
    if (!ref.mounted) return;
    if (blockedPackages.isEmpty || state.sessionId != sessionId) {
      return;
    }
    try {
      final repo = ref.read(sessionRepositoryProvider);
      for (final pkg in blockedPackages) {
        await repo.recordAttempt(sessionId: sessionId, blockedPackage: pkg);
      }
    } catch (_) {
      // A database hiccup must not break the countdown. The attempts were
      // already consumed natively, so keep the in-memory count in sync.
    }
    if (!ref.mounted) return;
    if (state.sessionId == sessionId && state.state == SessionState.active) {
      state = state.copyWith(
        attemptsCount: state.attemptsCount + blockedPackages.length,
      );
    }
  }

  void _onExternalSessionEnd() {
    if (state.state != SessionState.active) return;
    // Ending a stopwatch from the blocking overlay is how it normally ends;
    // only a countdown can be "ended early" by the user.
    _completeSession(endedEarly: !state.isStopwatch);
  }

  Future<void> endEarly() async {
    await _completeSession(endedEarly: true);
  }

  /// Ends the session in the normal way for the current mode.
  ///
  /// A countdown is ended early when the user stops it, while a stopwatch is
  /// simply finished at whatever duration it reached.
  Future<void> finishSession() async {
    await _completeSession(endedEarly: !state.isStopwatch);
  }

  Future<void> _completeSession({required bool endedEarly}) async {
    if (state.state != SessionState.active || _completing) return;
    _completing = true;
    _timer?.cancel();
    _timer = null;
    _ticksSinceAttemptsSync = 0;

    try {
      final sessionId = state.sessionId;
      final isStopwatch = state.isStopwatch;
      final startedAt = state.startedAt;
      final endsAt = state.endsAt;
      final attemptsCount = state.attemptsCount;
      final attemptsKnown = _attemptsKnown;
      final durationMinutes = state.durationMinutes;
      final elapsedSeconds = isStopwatch
          ? (startedAt == null
                ? state.elapsedSeconds
                : _secondsElapsed(startedAt))
          : state.elapsedSeconds;
      final startTime =
          _pendingStartTime ??
          startedAt ??
          (endsAt?.subtract(Duration(minutes: durationMinutes)) ??
              DateTime.now());

      BlockerPlatform.setExternalSessionEndHandler(null);

      if (sessionId == null) {
        state = SessionControllerState(
          state: SessionState.idle,
          durationMinutes: state.durationMinutes,
          mode: state.mode,
        );
        return;
      }

      // Show the feedback screen immediately. Database writes and the native
      // teardown are best-effort and must not hold the UI hostage.
      state = state.copyWith(
        state: SessionState.ended,
        endedEarly: endedEarly,
        remainingSeconds: 0,
        elapsedSeconds: elapsedSeconds,
      );

      unawaited(
        _finishSession(
          sessionId: sessionId,
          startTime: startTime,
          durationMinutes: durationMinutes,
          endedEarly: endedEarly,
          scheduledEnd: endsAt,
          attemptsCount: attemptsCount,
          attemptsKnown: attemptsKnown,
          isStopwatch: isStopwatch,
        ),
      );
    } finally {
      _completing = false;
    }
  }

  /// Stops the native service and persists the final session row.
  ///
  /// Runs after the UI has already moved to [SessionState.ended]. Every step
  /// is best-effort so a dead platform channel or a slow SQLite isolate
  /// cannot keep the user stuck on the timer screen.
  Future<void> _finishSession({
    required String sessionId,
    required DateTime startTime,
    required int durationMinutes,
    required bool endedEarly,
    required DateTime? scheduledEnd,
    required int attemptsCount,
    required bool attemptsKnown,
    required bool isStopwatch,
  }) async {
    var attempts = attemptsCount;
    // A stopwatch had no planned duration; the initial row (if it still has
    // to be written) is finalized below from the actual start/end times.
    final plannedDuration = isStopwatch ? 0 : durationMinutes;

    // Collect attempts recorded natively during the final seconds.
    final pending = await BlockerPlatform.consumePendingAttempts();
    // Do not tear down the native service if the user already started a new
    // session while this cleanup was in flight. The provider may also have
    // been disposed (app shutdown or test teardown); cleanup still completes,
    // but state must not be touched in that case.
    final newerSessionRunning =
        ref.mounted &&
        state.state == SessionState.active &&
        state.sessionId != null &&
        state.sessionId != sessionId;
    if (!newerSessionRunning) {
      if (endedEarly || isStopwatch) {
        await BlockerPlatform.endSession();
      } else {
        // Natural completion: let the native side show the completion
        // notification and vibrate. It is idempotent, so this does not
        // duplicate the alert if the service already finished the session.
        await BlockerPlatform.completeSession(sessionId: sessionId);
      }
    }

    await _persistSession(
      sessionId: sessionId,
      startTime: startTime,
      durationMinutes: plannedDuration,
    );

    if (pending.isNotEmpty) {
      try {
        final repo = ref.read(sessionRepositoryProvider);
        for (final pkg in pending) {
          // recordAttempt increments the stored count itself, which keeps the
          // data correct even when the in-memory count was unknown.
          await repo.recordAttempt(sessionId: sessionId, blockedPackage: pkg);
        }
        if (attemptsKnown) attempts += pending.length;
      } catch (_) {
        if (attemptsKnown) attempts += pending.length;
      }
    }

    try {
      await ref
          .read(sessionRepositoryProvider)
          .endSession(
            sessionId,
            endedEarly: endedEarly,
            attemptsCount: attemptsKnown ? attempts : null,
            // A naturally completed countdown ended when it was scheduled to,
            // not when Flutter happened to notice (possibly hours later after
            // being frozen by battery saver). Stopwatches and early endings
            // always finish now.
            endedAt: endedEarly || isStopwatch ? DateTime.now() : scheduledEnd,
          );
    } catch (_) {
      // Nothing else to do; the session is over from the user's point of view.
    }

    if (!ref.mounted) return;
    if (attemptsKnown &&
        state.sessionId == sessionId &&
        state.state == SessionState.ended &&
        state.attemptsCount != attempts) {
      state = state.copyWith(attemptsCount: attempts);
    }
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _ticksSinceAttemptsSync = 0;
    _pendingSessionId = null;
    _pendingStartTime = null;
    _pendingDurationMinutes = null;
    _sessionPersisted = false;
    _attemptsKnown = true;
    BlockerPlatform.setExternalSessionEndHandler(null);
    state = SessionControllerState(
      state: SessionState.idle,
      durationMinutes: state.durationMinutes,
      mode: state.mode,
    );
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionControllerState>(
      SessionController.new,
    );
