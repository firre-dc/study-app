import 'dart:convert';

import 'package:flutter/services.dart';

/// Snapshot of the session that the native foreground service is running.
///
/// The native side is the durable source of truth: it keeps running (and keeps
/// blocking) while Flutter is backgrounded, frozen by battery saver, or dead.
class NativeSessionState {
  const NativeSessionState({
    required this.active,
    required this.sessionId,
    required this.endsAt,
    required this.totalSeconds,
    required this.endedExternally,
  });

  final bool active;
  final String? sessionId;
  final DateTime? endsAt;
  final int totalSeconds;

  /// True when the user pressed "End Session" on the native blocking overlay.
  final bool endedExternally;

  static NativeSessionState? fromMap(Map<Object?, Object?>? map) {
    if (map == null) return null;
    final sessionId = map['sessionId'] as String?;
    final endTimeMillis = (map['endTimeMillis'] as num?)?.toInt() ?? 0;
    return NativeSessionState(
      active: map['active'] == true,
      sessionId: (sessionId == null || sessionId.isEmpty) ? null : sessionId,
      endsAt: endTimeMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis)
          : null,
      totalSeconds: (map['totalSeconds'] as num?)?.toInt() ?? 0,
      endedExternally: map['endedExternally'] == true,
    );
  }
}

class BlockerPlatform {
  BlockerPlatform._();

  static const _channel = MethodChannel('focusflow/blocker');

  /// Platform-channel calls are best-effort. A stuck native handler must
  /// never leave the UI waiting forever, so every call has a hard deadline.
  static const _callTimeout = Duration(seconds: 3);
  static const _startTimeout = Duration(seconds: 5);

  static void Function()? _externalSessionEndHandler;

  /// Native side pushes this event when the session was ended from the
  /// blocking overlay shown over a blocked app.
  static void setExternalSessionEndHandler(void Function()? handler) {
    _externalSessionEndHandler = handler;
    _channel.setMethodCallHandler(handler == null ? null : _handleNativeCall);
  }

  static Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onSessionEndedExternally':
        _externalSessionEndHandler?.call();
    }
    return null;
  }

  static Future<bool> isUsageAccessGranted() async {
    try {
      return await _channel
              .invokeMethod<bool>('isUsageAccessGranted')
              .timeout(_callTimeout) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canDrawOverlays() async {
    try {
      return await _channel
              .invokeMethod<bool>('canDrawOverlays')
              .timeout(_callTimeout) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openUsageAccessSettings() async {
    try {
      await _channel
          .invokeMethod('openUsageAccessSettings')
          .timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings').timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  /// Returns the session the native service is currently running, or null if
  /// the native side could not be reached (e.g. non-Android platforms).
  static Future<NativeSessionState?> getActiveSession() async {
    try {
      final result = await _channel
          .invokeMethod<Map<Object?, Object?>>('getActiveSession')
          .timeout(_callTimeout);
      return NativeSessionState.fromMap(result);
    } catch (_) {
      return null;
    }
  }

  /// Whether Android is allowed to aggressively stop this app in the
  /// background. When false, battery saver can kill the blocking service and
  /// the Flutter process mid-session.
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations')
              .timeout(_callTimeout) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Shows the system dialog asking to exempt FocusFlow from battery
  /// optimization. Falls back to the battery optimization settings list on
  /// devices that do not support the direct request.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel
          .invokeMethod('requestIgnoreBatteryOptimizations')
          .timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  static Future<void> startSession({
    required String sessionId,
    required DateTime endTime,
    required int totalSeconds,
    required List<String> whitelist,
  }) async {
    try {
      await _channel
          .invokeMethod('startSession', <String, dynamic>{
            'sessionId': sessionId,
            'endTimeMillis': endTime.millisecondsSinceEpoch,
            'totalSeconds': totalSeconds,
            'whitelist': jsonEncode(whitelist),
          })
          .timeout(_startTimeout);
    } catch (_) {
      // ignore
    }
  }

  static Future<void> endSession() async {
    try {
      await _channel.invokeMethod('endSession').timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  /// Finalizes a naturally completed session natively.
  ///
  /// The native side posts the completion notification and vibrates, then
  /// clears the session and stops the foreground service. It is idempotent,
  /// so it is safe to call even if the service already finished the session.
  static Future<void> completeSession({required String sessionId}) async {
    try {
      await _channel
          .invokeMethod('completeSession', <String, dynamic>{
            'sessionId': sessionId,
          })
          .timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  /// Requests the Android 13+ notification runtime permission. No-op on
  /// older Android versions and on other platforms.
  static Future<void> requestNotificationPermission() async {
    try {
      await _channel
          .invokeMethod('requestNotificationPermission')
          .timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  static Future<void> updateWhitelist(List<String> whitelist) async {
    try {
      await _channel
          .invokeMethod('updateWhitelist', <String, dynamic>{
            'whitelist': jsonEncode(whitelist),
          })
          .timeout(_callTimeout);
    } catch (_) {
      // ignore
    }
  }

  /// Returns and clears the block attempts recorded natively during the
  /// active session (package names, oldest first).
  static Future<List<String>> consumePendingAttempts() async {
    try {
      final result = await _channel
          .invokeMethod<List<dynamic>>('consumePendingAttempts')
          .timeout(_callTimeout);
      return result?.cast<String>() ?? const [];
    } catch (_) {
      return const [];
    }
  }
}
