import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/controllers/installed_apps_controller.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/apps_service.dart';
import 'package:study_app/services/blocker_platform.dart';
import 'package:study_app/widgets/app_selection_list.dart';

/// Post-onboarding whitelist editor: add/remove whitelisted apps from
/// Settings. The installed-app list is served from the cache instantly and
/// refreshes in the background (see [installedAppsProvider]).
class WhitelistEditorScreen extends ConsumerStatefulWidget {
  const WhitelistEditorScreen({super.key});

  @override
  ConsumerState<WhitelistEditorScreen> createState() =>
      _WhitelistEditorScreenState();
}

class _WhitelistEditorScreenState extends ConsumerState<WhitelistEditorScreen> {
  String _query = '';

  Future<void> _toggleApp(InstalledApp app, bool isSelected) async {
    if (isSelected) {
      await ref.read(whitelistRepositoryProvider).remove(app.packageName);
    } else {
      await ref.read(whitelistRepositoryProvider).add(
            AppWhitelistsCompanion.insert(
              packageName: app.packageName,
              appName: app.appName,
            ),
          );
    }
    await _syncBlockerWhitelist();
  }

  /// Keep the native blocker in sync with the DB (source of truth).
  Future<void> _syncBlockerWhitelist() async {
    final remaining = await ref.read(whitelistRepositoryProvider).getAll();
    await BlockerPlatform.updateWhitelist(
        remaining.map((a) => a.packageName).toList());
  }

  @override
  Widget build(BuildContext context) {
    final appsState =
        ref.watch(installedAppsProvider).value ?? const InstalledAppsState();
    final whitelist = ref.watch(whitelistProvider).value ?? [];
    final selectedPackages = whitelist.map((w) => w.packageName).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit whitelist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-scan installed apps',
            // Re-run the (slow) native scan on demand.
            onPressed: () =>
                ref.read(installedAppsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appsState.refreshing)
            const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search apps...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('${selectedPackages.length} whitelisted',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: appsState.loading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Scanning your apps...'),
                      ],
                    ),
                  )
                : AppSelectionList(
                    apps: appsState.apps,
                    query: _query,
                    selected: selectedPackages,
                    onToggle: (app) =>
                        _toggleApp(app, selectedPackages.contains(app.packageName)),
                    emptyMessage: _query.isEmpty
                        ? 'No apps found. Tap the refresh button to re-scan.'
                        : null,
                  ),
          ),
        ],
      ),
    );
  }
}
