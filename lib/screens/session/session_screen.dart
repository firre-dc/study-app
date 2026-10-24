import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/utils/time_utils.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIfNeeded();
    });
  }

  Future<void> _startIfNeeded() async {
    if (!mounted) return;
    final state = ref.read(sessionControllerProvider);
    if (state.state == SessionState.active) return;

    try {
      // startSession enters the active state synchronously, before any
      // database or platform-channel work, so the countdown always appears.
      await ref.read(sessionControllerProvider.notifier).startSession();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start the session: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);

    ref.listen<SessionControllerState>(sessionControllerProvider, (prev, next) {
      if (next.state == SessionState.ended) {
        context.go('/survey');
      }
    });

    final remaining = sessionState.remainingSeconds;
    final total = sessionState.durationMinutes * 60;
    final progress = total == 0 ? 0.0 : 1 - (remaining / total);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sessionState.state == SessionState.active
                        ? 'Stay focused!'
                        : 'Starting...',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Session in progress',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatDuration(remaining),
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'remaining',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (sessionState.attemptsCount > 0)
                    Text(
                      'Blocked ${sessionState.attemptsCount} attempt${sessionState.attemptsCount == 1 ? '' : 's'} to open distracting apps',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .endEarly();
                      if (context.mounted) context.go('/survey');
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    child: const Text('End session early'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
