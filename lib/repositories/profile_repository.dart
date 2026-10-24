import 'dart:convert';

import 'package:study_app/database/database.dart';

class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  Future<void> upsert(UserProfilesCompanion profile) async {
    await _db.into(_db.userProfiles).insertOnConflictUpdate(profile);
  }

  Future<UserProfile?> getProfile() async {
    final rows = await _db.select(_db.userProfiles).get();
    return rows.firstOrNull;
  }

  Stream<UserProfile?> watchProfile() {
    return _db.select(_db.userProfiles).watchSingleOrNull();
  }

  List<int> parseStudyDays(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<int>();
  }

  String encodeStudyDays(List<int> days) => jsonEncode(days);
}
