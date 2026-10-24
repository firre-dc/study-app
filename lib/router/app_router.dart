import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/screens/dashboard/dashboard_screen.dart';
import 'package:study_app/screens/onboarding/onboarding_flow.dart';
import 'package:study_app/screens/onboarding/permissions_screen.dart';
import 'package:study_app/screens/onboarding/profile_screen.dart';
import 'package:study_app/screens/onboarding/welcome_screen.dart';
import 'package:study_app/screens/onboarding/whitelist_screen.dart';
import 'package:study_app/screens/session/home_screen.dart';
import 'package:study_app/screens/session/session_screen.dart';
import 'package:study_app/screens/session/survey_screen.dart';
import 'package:study_app/screens/settings/settings_screen.dart';
import 'package:study_app/screens/settings/whitelist_editor_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingComplete.when(
      data: (complete) => complete ? '/' : '/onboarding',
      loading: () => '/loading',
      error: (_, _) => '/onboarding',
    ),
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlow(),
        routes: [
          GoRoute(path: 'welcome', builder: (context, state) => const WelcomeScreen()),
          GoRoute(path: 'profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: 'whitelist', builder: (context, state) => const WhitelistScreen()),
          GoRoute(path: 'permissions', builder: (context, state) => const PermissionsScreen()),
        ],
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(path: 'session', builder: (context, state) => const SessionScreen()),
          GoRoute(path: 'survey', builder: (context, state) => const SurveyScreen()),
          GoRoute(path: 'dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen(), routes: [
            GoRoute(
              path: 'whitelist',
              builder: (context, state) => const WhitelistEditorScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
