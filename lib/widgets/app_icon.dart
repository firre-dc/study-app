import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/controllers/installed_apps_controller.dart';
import 'package:study_app/services/apps_service.dart';

class AppIcon extends ConsumerWidget {
  const AppIcon({super.key, required this.packageName, this.size = 32});

  final String packageName;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(installedAppsProvider).value?.apps ?? const [];
    InstalledApp? app;
    for (final candidate in apps) {
      if (candidate.packageName == packageName) {
        app = candidate;
        break;
      }
    }
    final iconBase64 = app?.iconBase64;
    if (iconBase64 != null && iconBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(iconBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, width: size, height: size),
        );
      } catch (_) {
        // fall through
      }
    }
    return Icon(Icons.apps, size: size);
  }
}
