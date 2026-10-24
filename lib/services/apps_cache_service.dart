import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:study_app/services/apps_service.dart';

/// Persists the installed-app list on disk so the (very slow) native scan
/// only has to happen once; afterwards every cold start serves the cache
/// immediately while a background refresh runs.
class AppsCacheService {
  static const _fileName = 'focusflow_apps_cache.json';

  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }

  /// Returns the cached apps, or an empty list when missing/corrupt.
  Future<List<InstalledApp>> load() async {
    try {
      final file = File(await _path);
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map(_fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// Writes the cache atomically (best effort; failures are ignored so a
  /// broken cache can never break the app list UX).
  Future<void> save(List<InstalledApp> apps) async {
    try {
      final file = File(await _path);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        jsonEncode(apps.map(_toJson).toList()),
        flush: true,
      );
      await tmp.rename(file.path);
    } catch (_) {
      // Best-effort caching only.
    }
  }

  Map<String, dynamic> _toJson(InstalledApp app) => {
        'packageName': app.packageName,
        'appName': app.appName,
        'iconBase64': app.iconBase64,
      };

  InstalledApp _fromJson(dynamic item) {
    final map = item as Map<String, dynamic>;
    return InstalledApp(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      iconBase64: map['iconBase64'] as String?,
    );
  }
}
