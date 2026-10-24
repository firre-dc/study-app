import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/apps_service.dart';

class InstalledAppsState {
  const InstalledAppsState({
    this.apps = const [],
    this.loading = false,
    this.refreshing = false,
  });

  /// Installed apps, sorted by display name.
  final List<InstalledApp> apps;

  /// True while the very first scan is pending and no cached list exists yet.
  final bool loading;

  /// True while a background refresh is pending; `apps` may be served from
  /// the cache in the meantime.
  final bool refreshing;

  InstalledAppsState copyWith({
    List<InstalledApp>? apps,
    bool? loading,
    bool? refreshing,
  }) {
    return InstalledAppsState(
      apps: apps ?? this.apps,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

/// Serves the cached installed-app list instantly and keeps it fresh by
/// re-scanning in the background, because the native scan is very slow.
///
/// First launch after install (no cache yet) still needs to wait for the
/// scan; every subsequent launch shows the previous list immediately while
/// updated data (new/removed apps, renamed apps, refreshed icons) arrives.
class InstalledAppsController extends AsyncNotifier<InstalledAppsState> {
  // Guards against superseded refreshes writing stale results.
  int _refreshGeneration = 0;
  bool _autoRefreshScheduled = false;

  @override
  FutureOr<InstalledAppsState> build() async {
    ref.onDispose(() => _autoRefreshScheduled = false);

    final cached = List<InstalledApp>.from(
        await ref.watch(appsCacheServiceProvider).load());
    cached.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    // Keep the persisted list fresh; silently replaces state when done.
    if (!_autoRefreshScheduled) {
      _autoRefreshScheduled = true;
      unawaited(_autoRefresh());
    }

    return InstalledAppsState(apps: cached, loading: cached.isEmpty);
  }

  /// Re-scans installed apps immediately. An empty scan result is treated as
  /// a failure so a good cache is never wiped (enumeration returns [] when
  /// the channel errors out).
  Future<void> refresh() async {
    await _fetchAndCache();
  }

  Future<void> _autoRefresh() async {
    // One event-loop turn so the build resolves and the UI can paint the
    // cached list before the (expensive) scan starts.
    await Future<void>.delayed(Duration.zero);
    _autoRefreshScheduled = false;
    if (!ref.mounted) return;
    await _fetchAndCache();
  }

  Future<void> _fetchAndCache() async {
    final generation = ++_refreshGeneration;
    _setRefreshing(true);

    final fresh = await ref.read(appsServiceProvider).getLaunchableApps();
    if (generation != _refreshGeneration || !ref.mounted) return;

    if (fresh.isEmpty) {
      // Failed scan: keep the existing data, just clear the busy indicators
      // so the UI never hangs on a spinner.
      final current = state.value;
      if (current != null) {
        state = AsyncData(InstalledAppsState(
          apps: current.apps,
          loading: false,
          refreshing: false,
        ));
      }
      return;
    }

    // Update the UI first; persisting the cache afterwards is best-effort
    // (a slow or failed write must never delay fresh data).
    state = AsyncData(InstalledAppsState(apps: fresh, refreshing: false));
    if (generation != _refreshGeneration || !ref.mounted) return;
    unawaited(ref.read(appsCacheServiceProvider).save(fresh));
  }

  void _setRefreshing(bool value) {
    final current = state.value;
    if (current == null) return;
    if (ref.mounted) {
      state = AsyncData(current.copyWith(refreshing: value));
    }
  }
}

final installedAppsProvider =
    AsyncNotifierProvider<InstalledAppsController, InstalledAppsState>(
        InstalledAppsController.new);
