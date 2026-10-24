import 'dart:convert';

import 'package:flutter/services.dart';

class BlockerPlatform {
  BlockerPlatform._();

  static const _channel = MethodChannel('focusflow/blocker');

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
      return await _channel.invokeMethod<bool>('isUsageAccessGranted') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> canDrawOverlays() async {
    try {
      return await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openUsageAccessSettings() async {
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } on PlatformException {
      // ignore
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } on PlatformException {
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
      await _channel.invokeMethod('startSession', <String, dynamic>{
        'sessionId': sessionId,
        'endTimeMillis': endTime.millisecondsSinceEpoch,
        'totalSeconds': totalSeconds,
        'whitelist': jsonEncode(whitelist),
      });
    } on PlatformException {
      // ignore
    }
  }

  static Future<void> endSession() async {
    try {
      await _channel.invokeMethod('endSession');
    } on PlatformException {
      // ignore
    }
  }

  static Future<void> updateWhitelist(List<String> whitelist) async {
    try {
      await _channel.invokeMethod('updateWhitelist', <String, dynamic>{
        'whitelist': jsonEncode(whitelist),
      });
    } on PlatformException {
      // ignore
    }
  }

  /// Returns and clears the block attempts recorded natively during the
  /// active session (package names, oldest first).
  static Future<List<String>> consumePendingAttempts() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('consumePendingAttempts');
      return result?.cast<String>() ?? const [];
    } on PlatformException {
      return const [];
    }
  }
}
