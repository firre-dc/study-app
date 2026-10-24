import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get wakeTime => text()(); // HH:mm
  TextColumn get sleepTime => text()(); // HH:mm
  TextColumn get workStartTime => text().nullable()(); // HH:mm
  TextColumn get workEndTime => text().nullable()(); // HH:mm
  BoolColumn get drinksCaffeine => boolean().withDefault(const Constant(false))();
  TextColumn get caffeineTiming => text().nullable()(); // morning/afternoon/evening/other
  TextColumn get caffeineTime => text().nullable()(); // HH:mm
  TextColumn get chronotype => text().nullable()(); // early_bird/night_owl/normal
  TextColumn get studyDays => text().withDefault(const Constant('[]'))(); // JSON array of 0-6
  IntColumn get onboardingCompletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppWhitelists extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  TextColumn get iconPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {packageName};
}

class StudySessions extends Table {
  TextColumn get id => text()();
  IntColumn get startTime => integer()(); // millis
  IntColumn get endTime => integer()(); // millis
  RealColumn get durationMinutes => real()(); // precise minutes
  BoolColumn get endedEarly => boolean().withDefault(const Constant(false))();
  IntColumn get dayOfWeek => integer()(); // 0-6
  IntColumn get hourOfDay => integer()(); // 0-23
  TextColumn get timeBlock => text()(); // morning/afternoon/evening/late_night
  IntColumn get attemptsCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionFeedbacks extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(StudySessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get qProductivity => integer()(); // 1-10
  IntColumn get qFocus => integer()(); // 1-10
  IntColumn get qMentalTired => integer()(); // 1=very fresh, 10=very tired
  IntColumn get qPhysicalEnergy => integer()(); // 1=very low, 10=very high
  IntColumn get qDistracted => integer()(); // 1=not, 10=extremely
  BoolColumn get qUsedWhitelisted => boolean().withDefault(const Constant(false))();
  TextColumn get qUsedAppsJson => text().nullable()(); // JSON array of package names
  IntColumn get qSatisfaction => integer()(); // 1-10
  TextColumn get notes => text().nullable()();
  IntColumn get submittedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class BlockAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(StudySessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get blockedPackage => text()();
  IntColumn get attemptTime => integer()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  UserProfiles,
  AppWhitelists,
  StudySessions,
  SessionFeedbacks,
  BlockAttempts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Pre-release builds may have shipped schema changes without a
          // version bump; recreate so inserts never hit missing columns.
          for (final entity in allSchemaEntities.toList().reversed) {
            await m.deleteTable(entity.entityName);
          }
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/focusflow.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
