import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/controllers/onboarding_controller.dart';
import 'package:study_app/screens/onboarding/permissions_screen.dart';
import 'package:study_app/screens/onboarding/profile_screen.dart';
import 'package:study_app/screens/onboarding/welcome_screen.dart';
import 'package:study_app/screens/onboarding/whitelist_screen.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();

  void _onPageChanged(int page) {
    ref.read(onboardingControllerProvider.notifier).goToStep(page);
  }

  void _next() {
    final state = ref.read(onboardingControllerProvider);
    if (state.step == 1 && !state.profileComplete) return;
    _pageController.animateToPage(
      state.step + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    final state = ref.read(onboardingControllerProvider);
    if (state.step == 0) return;
    _pageController.animateToPage(
      state.step - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _complete() async {
    final state = ref.read(onboardingControllerProvider);
    if (!state.profileComplete || state.selectedPackages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all steps before finishing.')),
      );
      return;
    }
    try {
      await ref.read(onboardingControllerProvider.notifier).save();
    } catch (e, st) {
      debugPrint('Onboarding save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your setup: $e')),
        );
      }
      return;
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (state.step + 1) / 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: [
                  const WelcomeScreen(),
                  const ProfileScreen(),
                  const WhitelistScreen(),
                  const PermissionsScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (state.step > 0)
                    TextButton(
                      onPressed: _back,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (state.step == 0)
                    FilledButton(
                      onPressed: _next,
                      child: const Text('Next'),
                    )
                  else if (state.step == 1)
                    FilledButton(
                      onPressed: state.profileComplete ? _next : null,
                      child: const Text('Next'),
                    )
                  else if (state.step == 2)
                    FilledButton(
                      onPressed: state.selectedPackages.isEmpty ? null : _next,
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _complete,
                      child: const Text('Finish'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
