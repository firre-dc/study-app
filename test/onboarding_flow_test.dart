import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/controllers/onboarding_controller.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/main.dart';
import 'package:study_app/providers.dart';
import 'package:study_app/repositories/profile_repository.dart';
import 'package:study_app/repositories/whitelist_repository.dart';
import 'package:study_app/screens/session/home_screen.dart';
import 'package:study_app/services/apps_cache_service.dart';
import 'package:study_app/services/apps_service.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfilesCompanion? lastSaved;

  @override
  Future<void> upsert(UserProfilesCompanion profile) async {
    lastSaved = profile;
  }

  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Stream<UserProfile?> watchProfile() => const Stream.empty();

  @override
  List<int> parseStudyDays(String json) => [];

  @override
  String encodeStudyDays(List<int> days) => '[]';
}

class _FakeWhitelistRepository implements WhitelistRepository {
  List<AppWhitelistsCompanion> lastSaved = const [];

  @override
  Future<void> replaceAll(List<AppWhitelistsCompanion> apps) async {
    lastSaved = apps;
  }

  @override
  Future<void> add(AppWhitelistsCompanion app) async {}

  @override
  Future<void> remove(String packageName) async {}

  @override
  Future<List<AppWhitelist>> getAll() async => [];

  @override
  Stream<List<AppWhitelist>> watchAll() => const Stream.empty();
}

/// In-memory stand-in for the disk cache. Real (dart:io) reads/writes never
/// complete inside a FakeAsync widget test, so tests inject this fake via
/// [appsCacheServiceProvider] instead.
class _FakeAppsCache implements AppsCacheService {
  List<InstalledApp>? stored;

  @override
  Future<List<InstalledApp>> load() async => stored ?? const [];

  @override
  Future<void> save(List<InstalledApp> apps) async => stored = apps;
}

void main() {
  testWidgets('user can tap through onboarding and Finish completes it',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final binding =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    binding.setMockMethodCallHandler(
        const MethodChannel('focusflow/apps'), (call) async {
      if (call.method == 'getLaunchableApps') {
        return [
          {
            'packageName': 'com.example.app1',
            'appName': 'App One',
            'iconBase64': null,
          },
        ];
      }
      return null;
    });
    binding.setMockMethodCallHandler(
        const MethodChannel('focusflow/blocker'), (call) async {
      switch (call.method) {
        case 'isUsageAccessGranted':
        case 'canDrawOverlays':
          return false;
        default:
          return null;
      }
    });

    final profileRepo = _FakeProfileRepository();
    final whitelistRepo = _FakeWhitelistRepository();
    final appsCache = _FakeAppsCache();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profileRepo),
          whitelistRepositoryProvider.overrideWithValue(whitelistRepo),
          appsCacheServiceProvider.overrideWithValue(appsCache),
        ],
        child: const FocusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: welcome - Next must be enabled even though the profile is empty
    expect(find.text('Welcome to FocusFlow'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 1: profile - Next stays disabled until the profile is complete
    expect(find.text('Your routine'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNull,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FocusFlowApp)),
    );
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.setWakeTime(const TimeOfDay(hour: 7, minute: 0));
    controller.setSleepTime(const TimeOfDay(hour: 22, minute: 0));
    controller.setChronotype('regular');
    controller.toggleStudyDay(1);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: whitelist - select the app, then Next
    expect(find.text('Choose important apps'), findsOneWidget);
    await tester.tap(find.text('App One'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: permissions - Finish navigates home and persists everything
    expect(find.text('Permissions'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(profileRepo.lastSaved, isNotNull);
    expect(whitelistRepo.lastSaved.map((a) => a.packageName.value),
        ['com.example.app1']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_complete'), true);
  });

  testWidgets('Finish reports an error instead of failing silently',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final binding =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    binding.setMockMethodCallHandler(
        const MethodChannel('focusflow/apps'), (call) async {
      if (call.method == 'getLaunchableApps') {
        return [
          {
            'packageName': 'com.example.app1',
            'appName': 'App One',
            'iconBase64': null,
          },
        ];
      }
      return null;
    });
    binding.setMockMethodCallHandler(
        const MethodChannel('focusflow/blocker'), (call) async {
      switch (call.method) {
        case 'isUsageAccessGranted':
        case 'canDrawOverlays':
          return false;
        default:
          return null;
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider
              .overrideWithValue(_ThrowingProfileRepository()),
          whitelistRepositoryProvider
              .overrideWithValue(_FakeWhitelistRepository()),
          appsCacheServiceProvider.overrideWithValue(_FakeAppsCache()),
        ],
        child: const FocusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FocusFlowApp)),
    );
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.setWakeTime(const TimeOfDay(hour: 7, minute: 0));
    controller.setSleepTime(const TimeOfDay(hour: 22, minute: 0));
    controller.setChronotype('regular');
    controller.toggleStudyDay(1);
    controller.togglePackage('com.example.app1');
    controller.goToStep(3);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save your setup'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}

class _ThrowingProfileRepository implements ProfileRepository {
  @override
  Future<void> upsert(UserProfilesCompanion profile) async {
    throw Exception('disk full');
  }

  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Stream<UserProfile?> watchProfile() => const Stream.empty();

  @override
  List<int> parseStudyDays(String json) => [];

  @override
  String encodeStudyDays(List<int> days) => '[]';
}
