import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/controllers/installed_apps_controller.dart';
import 'package:study_app/controllers/onboarding_controller.dart';
import 'package:study_app/widgets/app_selection_list.dart';

class WhitelistScreen extends ConsumerStatefulWidget {
  const WhitelistScreen({super.key});

  @override
  ConsumerState<WhitelistScreen> createState() => _WhitelistScreenState();
}

class _WhitelistScreenState extends ConsumerState<WhitelistScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final appsState =
        ref.watch(installedAppsProvider).value ?? const InstalledAppsState();
    final selected = ref.watch(onboardingControllerProvider).selectedPackages;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose important apps',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'These apps will remain available during study sessions. Everything else is blocked.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search apps...',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
          const SizedBox(height: 8),
          Text('${selected.length} selected',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
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
                    selected: selected,
                    onToggle: (app) => ref
                        .read(onboardingControllerProvider.notifier)
                        .togglePackage(app.packageName),
                  ),
          ),
        ],
      ),
    );
  }
}
