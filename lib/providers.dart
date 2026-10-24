import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/repositories/dashboard_repository.dart';
import 'package:study_app/repositories/feedback_repository.dart';
import 'package:study_app/repositories/profile_repository.dart';
import 'package:study_app/repositories/session_repository.dart';
import 'package:study_app/repositories/whitelist_repository.dart';
import 'package:study_app/services/apps_cache_service.dart';
import 'package:study_app/services/apps_service.dart';
import 'package:study_app/services/blocker_platform.dart';
import 'package:study_app/services/prefs_service.dart';
import 'package:study_app/services/recommendation_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final whitelistRepositoryProvider = Provider<WhitelistRepository>(
  (ref) => WhitelistRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(databaseProvider)),
);

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepository(ref.watch(databaseProvider)),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(databaseProvider)),
);

final appsServiceProvider = Provider<AppsService>((ref) => AppsService());

final appsCacheServiceProvider = Provider<AppsCacheService>(
    (ref) => AppsCacheService());

final prefsServiceProvider = Provider<PrefsService>((ref) => PrefsService());

final recommendationServiceProvider =
    Provider<RecommendationService>((ref) => RecommendationService());

final blockerPlatformProvider = Provider<BlockerPlatform>((ref) => throw UnimplementedError());

final profileProvider = StreamProvider((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});

final whitelistProvider = StreamProvider((ref) {
  return ref.watch(whitelistRepositoryProvider).watchAll();
});

final whitelistPackagesProvider = Provider<Set<String>>((ref) {
  final whitelist = ref.watch(whitelistProvider).value ?? [];
  return whitelist.map((w) => w.packageName).toSet();
});

final sessionsProvider = StreamProvider((ref) {
  return ref.watch(sessionRepositoryProvider).watchAllSessions();
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) {
  return ref.watch(prefsServiceProvider).isOnboardingComplete();
});
