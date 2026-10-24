import 'package:flutter/services.dart';

class InstalledApp {
  InstalledApp({
    required this.packageName,
    required this.appName,
    this.iconBase64,
  });

  final String packageName;
  final String appName;
  final String? iconBase64;
}

class AppsService {
  static const _channel = MethodChannel('focusflow/apps');

  Future<List<InstalledApp>> getLaunchableApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getLaunchableApps');
      if (result == null) return [];
      return result.map((item) {
        final map = item as Map;
        return InstalledApp(
          packageName: map['packageName'] as String,
          appName: map['appName'] as String,
          iconBase64: map['iconBase64'] as String?,
        );
      }).toList()
        ..sort((a, b) =>
            a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } on PlatformException {
      return [];
    }
  }
}
