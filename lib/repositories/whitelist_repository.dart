import 'package:study_app/database/database.dart';

class WhitelistRepository {
  WhitelistRepository(this._db);
  final AppDatabase _db;

  Future<void> replaceAll(List<AppWhitelistsCompanion> apps) async {
    await _db.transaction(() async {
      await _db.delete(_db.appWhitelists).go();
      for (final app in apps) {
        await _db.into(_db.appWhitelists).insert(app);
      }
    });
  }

  Future<void> add(AppWhitelistsCompanion app) async {
    await _db.into(_db.appWhitelists).insertOnConflictUpdate(app);
  }

  Future<void> remove(String packageName) async {
    await (_db.delete(_db.appWhitelists)
          ..where((t) => t.packageName.equals(packageName)))
        .go();
  }

  Future<List<AppWhitelist>> getAll() => _db.select(_db.appWhitelists).get();

  Stream<List<AppWhitelist>> watchAll() =>
      _db.select(_db.appWhitelists).watch();
}
