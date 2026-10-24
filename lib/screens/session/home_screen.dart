import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/screens/session/permissions_gate.dart';
import 'package:study_app/screens/session/session_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: Padding(
        padding: const EdgeInsets.all(24),
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
