import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/screens/session/permissions_gate.dart';
import 'package:study_app/screens/session/session_screen.dart';
import 'package:study_app/services/blocker_platform.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _restoring = true;
  bool _ignoringBatteryOptimizations = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
      _checkBatteryOptimizations();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBatteryOptimizations();
    }
  }

  /// The Flutter process may have been killed by battery saver/OEM power
  /// management while the native foreground service kept the session alive.
  /// Pick that session back up instead of silently losing it.
  Future<void> _restoreSession() async {
    final result =
        await ref.read(sessionControllerProvider.notifier).restoreActiveSession();
    if (!mounted) return;
    setState(() => _restoring = false);
    if (result == SessionRestoreResult.active) {
      context.go('/session');
    } else if (result == SessionRestoreResult.ended) {
      context.go('/survey');
    }
  }

  Future<void> _checkBatteryOptimizations() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final ignoring = await BlockerPlatform.isIgnoringBatteryOptimizations();
    if (mounted && ignoring != _ignoringBatteryOptimizations) {
      setState(() => _ignoringBatteryOptimizations = ignoring);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight =
              constraints.maxHeight > 48 ? constraints.maxHeight - 48 : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
            Text(
              'Ready to focus?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a duration and start a session.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _DurationPicker(
              current: sessionState.durationMinutes,
              onChanged: (v) =>
                  ref.read(sessionControllerProvider.notifier).setDurationMinutes(v),
            ),
            if (!_ignoringBatteryOptimizations) ...[
              const SizedBox(height: 24),
              _BatteryWarningCard(
                onAllow: () => BlockerPlatform.requestIgnoreBatteryOptimizations(),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PermissionsGate(
                      child: SessionScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.insights),
              label: const Text('View Dashboard'),
            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BatteryWarningCard extends StatelessWidget {
  const _BatteryWarningCard({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.battery_alert, color: colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Battery saver can stop your session',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Allow FocusFlow to run in the background so the timer and app '
              'blocking keep working when the screen is off.',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onAllow,
              child: const Text('Allow background activity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const _presets = [10, 15, 25, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$current minutes', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _presets.map((m) {
            return ChoiceChip(
              label: Text('$m min'),
              selected: current == m,
              onSelected: (_) => onChanged(m),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: current > 1 ? () => onChanged(current - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              onPressed: () => onChanged(current + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
