import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/services/blocker_platform.dart';
import 'package:study_app/utils/time_utils.dart';
import 'package:study_app/widgets/app_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final whitelist = ref.watch(whitelistProvider).value ?? [];
    final workStart = profile?.workStartTime;
    final workEnd = profile?.workEndTime;
    final caffeineTiming = profile?.caffeineTiming;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Profile'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Wake time'),
                  trailing: Text(profile?.wakeTime ?? '--:--'),
                ),
                ListTile(
                  title: const Text('Sleep time'),
                  trailing: Text(profile?.sleepTime ?? '--:--'),
                ),
                if (workStart != null && workStart.isNotEmpty)
                  ListTile(
                    title: const Text('Work/school start'),
                    trailing: Text(workStart),
                  ),
                if (workEnd != null && workEnd.isNotEmpty)
                  ListTile(
                    title: const Text('Work/school end'),
                    trailing: Text(workEnd),
                  ),
                ListTile(
                  title: const Text('Drinks caffeine'),
                  trailing: Text(profile?.drinksCaffeine == true ? 'Yes' : 'No'),
                ),
                if (profile?.drinksCaffeine == true && caffeineTiming != null)
                  ListTile(
                    title: const Text('Caffeine timing'),
                    trailing: Text(caffeineTiming),
                  ),
                ListTile(
                  title: const Text('Chronotype'),
                  trailing: Text(profile?.chronotype ?? '-'),
                ),
                ListTile(
                  title: const Text('Study days'),
                  trailing: Text(profile != null
                      ? ref
                          .read(profileRepositoryProvider)
                          .parseStudyDays(profile.studyDays)
                          .map(dayLabel)
                          .join(', ')
                      : '-'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Whitelist (${whitelist.length} apps)'),
          Card(
            child: Column(
              children: [
                if (whitelist.isEmpty)
                  const ListTile(title: Text('No apps selected'))
                else
                  ...whitelist.map((app) => ListTile(
                        leading: AppIcon(packageName: app.packageName, size: 24),
                        title: Text(app.appName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(whitelistRepositoryProvider)
                                .remove(app.packageName);
                            final remaining = await ref
                                .read(whitelistRepositoryProvider)
                                .getAll();
                            await BlockerPlatform.updateWhitelist(remaining
                                .map((a) => a.packageName)
                                .toList());
                          },
                        ),
                      )),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit whitelist'),
                  subtitle: const Text('Add or remove apps after onboarding'),
                  onTap: () => context.go('/settings/whitelist'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Permissions'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.data_usage),
                  title: const Text('Usage access'),
                  trailing: FutureBuilder(
                    future: BlockerPlatform.isUsageAccessGranted(),
                    builder: (context, snapshot) => Icon(
                      snapshot.data == true
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          snapshot.data == true ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () => BlockerPlatform.openUsageAccessSettings(),
                ),
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('Display over other apps'),
                  trailing: FutureBuilder(
                    future: BlockerPlatform.canDrawOverlays(),
                    builder: (context, snapshot) => Icon(
                      snapshot.data == true
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          snapshot.data == true ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () => BlockerPlatform.openOverlaySettings(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('About'),
          Card(
            child: Column(
              children: const [
                ListTile(
                    title: Text('FocusFlow'), subtitle: Text('Version 1.0.0')),
                ListTile(
                  title: Text('Local-only'),
                  subtitle: Text('All your data stays on this device.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
