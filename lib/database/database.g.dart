// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeTimeMeta = const VerificationMeta(
    'wakeTime',
  );
  @override
  late final GeneratedColumn<String> wakeTime = GeneratedColumn<String>(
    'wake_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepTimeMeta = const VerificationMeta(
    'sleepTime',
  );
  @override
  late final GeneratedColumn<String> sleepTime = GeneratedColumn<String>(
    'sleep_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workStartTimeMeta = const VerificationMeta(
    'workStartTime',
  );
  @override
  late final GeneratedColumn<String> workStartTime = GeneratedColumn<String>(
    'work_start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workEndTimeMeta = const VerificationMeta(
    'workEndTime',
  );
  @override
  late final GeneratedColumn<String> workEndTime = GeneratedColumn<String>(
    'work_end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drinksCaffeineMeta = const VerificationMeta(
    'drinksCaffeine',
  );
  @override
  late final GeneratedColumn<bool> drinksCaffeine = GeneratedColumn<bool>(
    'drinks_caffeine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("drinks_caffeine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _caffeineTimingMeta = const VerificationMeta(
    'caffeineTiming',
  );
  @override
  late final GeneratedColumn<String> caffeineTiming = GeneratedColumn<String>(
    'caffeine_timing',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caffeineTimeMeta = const VerificationMeta(
    'caffeineTime',
  );
  @override
  late final GeneratedColumn<String> caffeineTime = GeneratedColumn<String>(
    'caffeine_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chronotypeMeta = const VerificationMeta(
    'chronotype',
  );
  @override
  late final GeneratedColumn<String> chronotype = GeneratedColumn<String>(
    'chronotype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studyDaysMeta = const VerificationMeta(
    'studyDays',
  );
  @override
  late final GeneratedColumn<String> studyDays = GeneratedColumn<String>(
    'study_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<int> onboardingCompletedAt = GeneratedColumn<int>(
    'onboarding_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wakeTime,
    sleepTime,
    workStartTime,
    workEndTime,
    drinksCaffeine,
    caffeineTiming,
    caffeineTime,
    chronotype,
    studyDays,
    onboardingCompletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wake_time')) {
      context.handle(
        _wakeTimeMeta,
        wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeTimeMeta);
    }
    if (data.containsKey('sleep_time')) {
      context.handle(
        _sleepTimeMeta,
        sleepTime.isAcceptableOrUnknown(data['sleep_time']!, _sleepTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_sleepTimeMeta);
    }
    if (data.containsKey('work_start_time')) {
      context.handle(
        _workStartTimeMeta,
        workStartTime.isAcceptableOrUnknown(
          data['work_start_time']!,
          _workStartTimeMeta,
        ),
      );
    }
    if (data.containsKey('work_end_time')) {
      context.handle(
        _workEndTimeMeta,
        workEndTime.isAcceptableOrUnknown(
          data['work_end_time']!,
          _workEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('drinks_caffeine')) {
      context.handle(
        _drinksCaffeineMeta,
        drinksCaffeine.isAcceptableOrUnknown(
          data['drinks_caffeine']!,
          _drinksCaffeineMeta,
        ),
      );
    }
    if (data.containsKey('caffeine_timing')) {
      context.handle(
        _caffeineTimingMeta,
        caffeineTiming.isAcceptableOrUnknown(
          data['caffeine_timing']!,
          _caffeineTimingMeta,
        ),
      );
    }
    if (data.containsKey('caffeine_time')) {
      context.handle(
        _caffeineTimeMeta,
        caffeineTime.isAcceptableOrUnknown(
          data['caffeine_time']!,
          _caffeineTimeMeta,
        ),
      );
    }
    if (data.containsKey('chronotype')) {
      context.handle(
        _chronotypeMeta,
        chronotype.isAcceptableOrUnknown(data['chronotype']!, _chronotypeMeta),
      );
    }
    if (data.containsKey('study_days')) {
      context.handle(
        _studyDaysMeta,
        studyDays.isAcceptableOrUnknown(data['study_days']!, _studyDaysMeta),
      );
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
        _onboardingCompletedAtMeta,
        onboardingCompletedAt.isAcceptableOrUnknown(
          data['onboarding_completed_at']!,
          _onboardingCompletedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wake_time'],
      )!,
      sleepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sleep_time'],
      )!,
      workStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_start_time'],
      ),
      workEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_end_time'],
      ),
      drinksCaffeine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}drinks_caffeine'],
      )!,
      caffeineTiming: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caffeine_timing'],
      ),
      caffeineTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caffeine_time'],
      ),
      chronotype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chronotype'],
      ),
      studyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_days'],
      )!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_completed_at'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String wakeTime;
  final String sleepTime;
  final String? workStartTime;
  final String? workEndTime;
  final bool drinksCaffeine;
  final String? caffeineTiming;
  final String? caffeineTime;
  final String? chronotype;
  final String studyDays;
  final int? onboardingCompletedAt;
  const UserProfile({
    required this.id,
    required this.wakeTime,
    required this.sleepTime,
    this.workStartTime,
    this.workEndTime,
    required this.drinksCaffeine,
    this.caffeineTiming,
    this.caffeineTime,
    this.chronotype,
    required this.studyDays,
    this.onboardingCompletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wake_time'] = Variable<String>(wakeTime);
    map['sleep_time'] = Variable<String>(sleepTime);
    if (!nullToAbsent || workStartTime != null) {
      map['work_start_time'] = Variable<String>(workStartTime);
    }
    if (!nullToAbsent || workEndTime != null) {
      map['work_end_time'] = Variable<String>(workEndTime);
    }
    map['drinks_caffeine'] = Variable<bool>(drinksCaffeine);
    if (!nullToAbsent || caffeineTiming != null) {
      map['caffeine_timing'] = Variable<String>(caffeineTiming);
    }
    if (!nullToAbsent || caffeineTime != null) {
      map['caffeine_time'] = Variable<String>(caffeineTime);
    }
    if (!nullToAbsent || chronotype != null) {
      map['chronotype'] = Variable<String>(chronotype);
    }
    map['study_days'] = Variable<String>(studyDays);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<int>(onboardingCompletedAt);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      wakeTime: Value(wakeTime),
      sleepTime: Value(sleepTime),
      workStartTime: workStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(workStartTime),
      workEndTime: workEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(workEndTime),
      drinksCaffeine: Value(drinksCaffeine),
      caffeineTiming: caffeineTiming == null && nullToAbsent
          ? const Value.absent()
          : Value(caffeineTiming),
      caffeineTime: caffeineTime == null && nullToAbsent
          ? const Value.absent()
          : Value(caffeineTime),
      chronotype: chronotype == null && nullToAbsent
          ? const Value.absent()
          : Value(chronotype),
      studyDays: Value(studyDays),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      wakeTime: serializer.fromJson<String>(json['wakeTime']),
      sleepTime: serializer.fromJson<String>(json['sleepTime']),
      workStartTime: serializer.fromJson<String?>(json['workStartTime']),
      workEndTime: serializer.fromJson<String?>(json['workEndTime']),
      drinksCaffeine: serializer.fromJson<bool>(json['drinksCaffeine']),
      caffeineTiming: serializer.fromJson<String?>(json['caffeineTiming']),
      caffeineTime: serializer.fromJson<String?>(json['caffeineTime']),
      chronotype: serializer.fromJson<String?>(json['chronotype']),
      studyDays: serializer.fromJson<String>(json['studyDays']),
      onboardingCompletedAt: serializer.fromJson<int?>(
        json['onboardingCompletedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wakeTime': serializer.toJson<String>(wakeTime),
      'sleepTime': serializer.toJson<String>(sleepTime),
      'workStartTime': serializer.toJson<String?>(workStartTime),
      'workEndTime': serializer.toJson<String?>(workEndTime),
      'drinksCaffeine': serializer.toJson<bool>(drinksCaffeine),
      'caffeineTiming': serializer.toJson<String?>(caffeineTiming),
      'caffeineTime': serializer.toJson<String?>(caffeineTime),
      'chronotype': serializer.toJson<String?>(chronotype),
      'studyDays': serializer.toJson<String>(studyDays),
      'onboardingCompletedAt': serializer.toJson<int?>(onboardingCompletedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? wakeTime,
    String? sleepTime,
    Value<String?> workStartTime = const Value.absent(),
    Value<String?> workEndTime = const Value.absent(),
    bool? drinksCaffeine,
    Value<String?> caffeineTiming = const Value.absent(),
    Value<String?> caffeineTime = const Value.absent(),
    Value<String?> chronotype = const Value.absent(),
    String? studyDays,
    Value<int?> onboardingCompletedAt = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    wakeTime: wakeTime ?? this.wakeTime,
    sleepTime: sleepTime ?? this.sleepTime,
    workStartTime: workStartTime.present
        ? workStartTime.value
        : this.workStartTime,
    workEndTime: workEndTime.present ? workEndTime.value : this.workEndTime,
    drinksCaffeine: drinksCaffeine ?? this.drinksCaffeine,
    caffeineTiming: caffeineTiming.present
        ? caffeineTiming.value
        : this.caffeineTiming,
    caffeineTime: caffeineTime.present ? caffeineTime.value : this.caffeineTime,
    chronotype: chronotype.present ? chronotype.value : this.chronotype,
    studyDays: studyDays ?? this.studyDays,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      sleepTime: data.sleepTime.present ? data.sleepTime.value : this.sleepTime,
      workStartTime: data.workStartTime.present
          ? data.workStartTime.value
          : this.workStartTime,
      workEndTime: data.workEndTime.present
          ? data.workEndTime.value
          : this.workEndTime,
      drinksCaffeine: data.drinksCaffeine.present
          ? data.drinksCaffeine.value
          : this.drinksCaffeine,
      caffeineTiming: data.caffeineTiming.present
          ? data.caffeineTiming.value
          : this.caffeineTiming,
      caffeineTime: data.caffeineTime.present
          ? data.caffeineTime.value
          : this.caffeineTime,
      chronotype: data.chronotype.present
          ? data.chronotype.value
          : this.chronotype,
      studyDays: data.studyDays.present ? data.studyDays.value : this.studyDays,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('workStartTime: $workStartTime, ')
          ..write('workEndTime: $workEndTime, ')
          ..write('drinksCaffeine: $drinksCaffeine, ')
          ..write('caffeineTiming: $caffeineTiming, ')
          ..write('caffeineTime: $caffeineTime, ')
          ..write('chronotype: $chronotype, ')
          ..write('studyDays: $studyDays, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wakeTime,
    sleepTime,
    workStartTime,
    workEndTime,
    drinksCaffeine,
    caffeineTiming,
    caffeineTime,
    chronotype,
    studyDays,
    onboardingCompletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.wakeTime == this.wakeTime &&
          other.sleepTime == this.sleepTime &&
          other.workStartTime == this.workStartTime &&
          other.workEndTime == this.workEndTime &&
          other.drinksCaffeine == this.drinksCaffeine &&
          other.caffeineTiming == this.caffeineTiming &&
          other.caffeineTime == this.caffeineTime &&
          other.chronotype == this.chronotype &&
          other.studyDays == this.studyDays &&
          other.onboardingCompletedAt == this.onboardingCompletedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> wakeTime;
  final Value<String> sleepTime;
  final Value<String?> workStartTime;
  final Value<String?> workEndTime;
  final Value<bool> drinksCaffeine;
  final Value<String?> caffeineTiming;
  final Value<String?> caffeineTime;
  final Value<String?> chronotype;
  final Value<String> studyDays;
  final Value<int?> onboardingCompletedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.workStartTime = const Value.absent(),
    this.workEndTime = const Value.absent(),
    this.drinksCaffeine = const Value.absent(),
    this.caffeineTiming = const Value.absent(),
    this.caffeineTime = const Value.absent(),
    this.chronotype = const Value.absent(),
    this.studyDays = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String wakeTime,
    required String sleepTime,
    this.workStartTime = const Value.absent(),
    this.workEndTime = const Value.absent(),
    this.drinksCaffeine = const Value.absent(),
    this.caffeineTiming = const Value.absent(),
    this.caffeineTime = const Value.absent(),
    this.chronotype = const Value.absent(),
    this.studyDays = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wakeTime = Value(wakeTime),
       sleepTime = Value(sleepTime);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? wakeTime,
    Expression<String>? sleepTime,
    Expression<String>? workStartTime,
    Expression<String>? workEndTime,
    Expression<bool>? drinksCaffeine,
    Expression<String>? caffeineTiming,
    Expression<String>? caffeineTime,
    Expression<String>? chronotype,
    Expression<String>? studyDays,
    Expression<int>? onboardingCompletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (sleepTime != null) 'sleep_time': sleepTime,
      if (workStartTime != null) 'work_start_time': workStartTime,
      if (workEndTime != null) 'work_end_time': workEndTime,
      if (drinksCaffeine != null) 'drinks_caffeine': drinksCaffeine,
      if (caffeineTiming != null) 'caffeine_timing': caffeineTiming,
      if (caffeineTime != null) 'caffeine_time': caffeineTime,
      if (chronotype != null) 'chronotype': chronotype,
      if (studyDays != null) 'study_days': studyDays,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? wakeTime,
    Value<String>? sleepTime,
    Value<String?>? workStartTime,
    Value<String?>? workEndTime,
    Value<bool>? drinksCaffeine,
    Value<String?>? caffeineTiming,
    Value<String?>? caffeineTime,
    Value<String?>? chronotype,
    Value<String>? studyDays,
    Value<int?>? onboardingCompletedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      drinksCaffeine: drinksCaffeine ?? this.drinksCaffeine,
      caffeineTiming: caffeineTiming ?? this.caffeineTiming,
      caffeineTime: caffeineTime ?? this.caffeineTime,
      chronotype: chronotype ?? this.chronotype,
      studyDays: studyDays ?? this.studyDays,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<String>(wakeTime.value);
    }
    if (sleepTime.present) {
      map['sleep_time'] = Variable<String>(sleepTime.value);
    }
    if (workStartTime.present) {
      map['work_start_time'] = Variable<String>(workStartTime.value);
    }
    if (workEndTime.present) {
      map['work_end_time'] = Variable<String>(workEndTime.value);
    }
    if (drinksCaffeine.present) {
      map['drinks_caffeine'] = Variable<bool>(drinksCaffeine.value);
    }
    if (caffeineTiming.present) {
      map['caffeine_timing'] = Variable<String>(caffeineTiming.value);
    }
    if (caffeineTime.present) {
      map['caffeine_time'] = Variable<String>(caffeineTime.value);
    }
    if (chronotype.present) {
      map['chronotype'] = Variable<String>(chronotype.value);
    }
    if (studyDays.present) {
      map['study_days'] = Variable<String>(studyDays.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<int>(
        onboardingCompletedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('workStartTime: $workStartTime, ')
          ..write('workEndTime: $workEndTime, ')
          ..write('drinksCaffeine: $drinksCaffeine, ')
          ..write('caffeineTiming: $caffeineTiming, ')
          ..write('caffeineTime: $caffeineTime, ')
          ..write('chronotype: $chronotype, ')
          ..write('studyDays: $studyDays, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppWhitelistsTable extends AppWhitelists
    with TableInfo<$AppWhitelistsTable, AppWhitelist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppWhitelistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [packageName, appName, iconPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_whitelists';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppWhitelist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  AppWhitelist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppWhitelist(
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
    );
  }

  @override
  $AppWhitelistsTable createAlias(String alias) {
    return $AppWhitelistsTable(attachedDatabase, alias);
  }
}

class AppWhitelist extends DataClass implements Insertable<AppWhitelist> {
  final String packageName;
  final String appName;
  final String? iconPath;
  const AppWhitelist({
    required this.packageName,
    required this.appName,
    this.iconPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    return map;
  }

  AppWhitelistsCompanion toCompanion(bool nullToAbsent) {
    return AppWhitelistsCompanion(
      packageName: Value(packageName),
      appName: Value(appName),
      iconPath: iconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(iconPath),
    );
  }

  factory AppWhitelist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppWhitelist(
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'iconPath': serializer.toJson<String?>(iconPath),
    };
  }

  AppWhitelist copyWith({
    String? packageName,
    String? appName,
    Value<String?> iconPath = const Value.absent(),
  }) => AppWhitelist(
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
  );
  AppWhitelist copyWithCompanion(AppWhitelistsCompanion data) {
    return AppWhitelist(
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppWhitelist(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconPath: $iconPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(packageName, appName, iconPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppWhitelist &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.iconPath == this.iconPath);
}

class AppWhitelistsCompanion extends UpdateCompanion<AppWhitelist> {
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String?> iconPath;
  final Value<int> rowid;
  const AppWhitelistsCompanion({
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppWhitelistsCompanion.insert({
    required String packageName,
    required String appName,
    this.iconPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName),
       appName = Value(appName);
  static Insertable<AppWhitelist> custom({
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? iconPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (iconPath != null) 'icon_path': iconPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppWhitelistsCompanion copyWith({
    Value<String>? packageName,
    Value<String>? appName,
    Value<String?>? iconPath,
    Value<int>? rowid,
  }) {
    return AppWhitelistsCompanion(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconPath: iconPath ?? this.iconPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppWhitelistsCompanion(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconPath: $iconPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<double> durationMinutes = GeneratedColumn<double>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedEarlyMeta = const VerificationMeta(
    'endedEarly',
  );
  @override
  late final GeneratedColumn<bool> endedEarly = GeneratedColumn<bool>(
    'ended_early',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ended_early" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourOfDayMeta = const VerificationMeta(
    'hourOfDay',
  );
  @override
  late final GeneratedColumn<int> hourOfDay = GeneratedColumn<int>(
    'hour_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeBlockMeta = const VerificationMeta(
    'timeBlock',
  );
  @override
  late final GeneratedColumn<String> timeBlock = GeneratedColumn<String>(
    'time_block',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsCountMeta = const VerificationMeta(
    'attemptsCount',
  );
  @override
  late final GeneratedColumn<int> attemptsCount = GeneratedColumn<int>(
    'attempts_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    durationMinutes,
    endedEarly,
    dayOfWeek,
    hourOfDay,
    timeBlock,
    attemptsCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('ended_early')) {
      context.handle(
        _endedEarlyMeta,
        endedEarly.isAcceptableOrUnknown(data['ended_early']!, _endedEarlyMeta),
      );
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('hour_of_day')) {
      context.handle(
        _hourOfDayMeta,
        hourOfDay.isAcceptableOrUnknown(data['hour_of_day']!, _hourOfDayMeta),
      );
    } else if (isInserting) {
      context.missing(_hourOfDayMeta);
    }
    if (data.containsKey('time_block')) {
      context.handle(
        _timeBlockMeta,
        timeBlock.isAcceptableOrUnknown(data['time_block']!, _timeBlockMeta),
      );
    } else if (isInserting) {
      context.missing(_timeBlockMeta);
    }
    if (data.containsKey('attempts_count')) {
      context.handle(
        _attemptsCountMeta,
        attemptsCount.isAcceptableOrUnknown(
          data['attempts_count']!,
          _attemptsCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_minutes'],
      )!,
      endedEarly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ended_early'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      hourOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour_of_day'],
      )!,
      timeBlock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_block'],
      )!,
      attemptsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final int startTime;
  final int endTime;
  final double durationMinutes;
  final bool endedEarly;
  final int dayOfWeek;
  final int hourOfDay;
  final String timeBlock;
  final int attemptsCount;
  final int createdAt;
  const StudySession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.endedEarly,
    required this.dayOfWeek,
    required this.hourOfDay,
    required this.timeBlock,
    required this.attemptsCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    map['duration_minutes'] = Variable<double>(durationMinutes);
    map['ended_early'] = Variable<bool>(endedEarly);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['hour_of_day'] = Variable<int>(hourOfDay);
    map['time_block'] = Variable<String>(timeBlock);
    map['attempts_count'] = Variable<int>(attemptsCount);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationMinutes: Value(durationMinutes),
      endedEarly: Value(endedEarly),
      dayOfWeek: Value(dayOfWeek),
      hourOfDay: Value(hourOfDay),
      timeBlock: Value(timeBlock),
      attemptsCount: Value(attemptsCount),
      createdAt: Value(createdAt),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      durationMinutes: serializer.fromJson<double>(json['durationMinutes']),
      endedEarly: serializer.fromJson<bool>(json['endedEarly']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      hourOfDay: serializer.fromJson<int>(json['hourOfDay']),
      timeBlock: serializer.fromJson<String>(json['timeBlock']),
      attemptsCount: serializer.fromJson<int>(json['attemptsCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'durationMinutes': serializer.toJson<double>(durationMinutes),
      'endedEarly': serializer.toJson<bool>(endedEarly),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'hourOfDay': serializer.toJson<int>(hourOfDay),
      'timeBlock': serializer.toJson<String>(timeBlock),
      'attemptsCount': serializer.toJson<int>(attemptsCount),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StudySession copyWith({
    String? id,
    int? startTime,
    int? endTime,
    double? durationMinutes,
    bool? endedEarly,
    int? dayOfWeek,
    int? hourOfDay,
    String? timeBlock,
    int? attemptsCount,
    int? createdAt,
  }) => StudySession(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    endedEarly: endedEarly ?? this.endedEarly,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    hourOfDay: hourOfDay ?? this.hourOfDay,
    timeBlock: timeBlock ?? this.timeBlock,
    attemptsCount: attemptsCount ?? this.attemptsCount,
    createdAt: createdAt ?? this.createdAt,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      endedEarly: data.endedEarly.present
          ? data.endedEarly.value
          : this.endedEarly,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      hourOfDay: data.hourOfDay.present ? data.hourOfDay.value : this.hourOfDay,
      timeBlock: data.timeBlock.present ? data.timeBlock.value : this.timeBlock,
      attemptsCount: data.attemptsCount.present
          ? data.attemptsCount.value
          : this.attemptsCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('endedEarly: $endedEarly, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('hourOfDay: $hourOfDay, ')
          ..write('timeBlock: $timeBlock, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    durationMinutes,
    endedEarly,
    dayOfWeek,
    hourOfDay,
    timeBlock,
    attemptsCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationMinutes == this.durationMinutes &&
          other.endedEarly == this.endedEarly &&
          other.dayOfWeek == this.dayOfWeek &&
          other.hourOfDay == this.hourOfDay &&
          other.timeBlock == this.timeBlock &&
          other.attemptsCount == this.attemptsCount &&
          other.createdAt == this.createdAt);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<double> durationMinutes;
  final Value<bool> endedEarly;
  final Value<int> dayOfWeek;
  final Value<int> hourOfDay;
  final Value<String> timeBlock;
  final Value<int> attemptsCount;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.endedEarly = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.hourOfDay = const Value.absent(),
    this.timeBlock = const Value.absent(),
    this.attemptsCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required int startTime,
    required int endTime,
    required double durationMinutes,
    this.endedEarly = const Value.absent(),
    required int dayOfWeek,
    required int hourOfDay,
    required String timeBlock,
    this.attemptsCount = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes),
       dayOfWeek = Value(dayOfWeek),
       hourOfDay = Value(hourOfDay),
       timeBlock = Value(timeBlock),
       createdAt = Value(createdAt);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<double>? durationMinutes,
    Expression<bool>? endedEarly,
    Expression<int>? dayOfWeek,
    Expression<int>? hourOfDay,
    Expression<String>? timeBlock,
    Expression<int>? attemptsCount,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (endedEarly != null) 'ended_early': endedEarly,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (hourOfDay != null) 'hour_of_day': hourOfDay,
      if (timeBlock != null) 'time_block': timeBlock,
      if (attemptsCount != null) 'attempts_count': attemptsCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<double>? durationMinutes,
    Value<bool>? endedEarly,
    Value<int>? dayOfWeek,
    Value<int>? hourOfDay,
    Value<String>? timeBlock,
    Value<int>? attemptsCount,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      endedEarly: endedEarly ?? this.endedEarly,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      hourOfDay: hourOfDay ?? this.hourOfDay,
      timeBlock: timeBlock ?? this.timeBlock,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<double>(durationMinutes.value);
    }
    if (endedEarly.present) {
      map['ended_early'] = Variable<bool>(endedEarly.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (hourOfDay.present) {
      map['hour_of_day'] = Variable<int>(hourOfDay.value);
    }
    if (timeBlock.present) {
      map['time_block'] = Variable<String>(timeBlock.value);
    }
    if (attemptsCount.present) {
      map['attempts_count'] = Variable<int>(attemptsCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('endedEarly: $endedEarly, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('hourOfDay: $hourOfDay, ')
          ..write('timeBlock: $timeBlock, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionFeedbacksTable extends SessionFeedbacks
    with TableInfo<$SessionFeedbacksTable, SessionFeedback> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionFeedbacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _qProductivityMeta = const VerificationMeta(
    'qProductivity',
  );
  @override
  late final GeneratedColumn<int> qProductivity = GeneratedColumn<int>(
    'q_productivity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qFocusMeta = const VerificationMeta('qFocus');
  @override
  late final GeneratedColumn<int> qFocus = GeneratedColumn<int>(
    'q_focus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qMentalTiredMeta = const VerificationMeta(
    'qMentalTired',
  );
  @override
  late final GeneratedColumn<int> qMentalTired = GeneratedColumn<int>(
    'q_mental_tired',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qPhysicalEnergyMeta = const VerificationMeta(
    'qPhysicalEnergy',
  );
  @override
  late final GeneratedColumn<int> qPhysicalEnergy = GeneratedColumn<int>(
    'q_physical_energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qDistractedMeta = const VerificationMeta(
    'qDistracted',
  );
  @override
  late final GeneratedColumn<int> qDistracted = GeneratedColumn<int>(
    'q_distracted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qUsedWhitelistedMeta = const VerificationMeta(
    'qUsedWhitelisted',
  );
  @override
  late final GeneratedColumn<bool> qUsedWhitelisted = GeneratedColumn<bool>(
    'q_used_whitelisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("q_used_whitelisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _qUsedAppsJsonMeta = const VerificationMeta(
    'qUsedAppsJson',
  );
  @override
  late final GeneratedColumn<String> qUsedAppsJson = GeneratedColumn<String>(
    'q_used_apps_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qSatisfactionMeta = const VerificationMeta(
    'qSatisfaction',
  );
  @override
  late final GeneratedColumn<int> qSatisfaction = GeneratedColumn<int>(
    'q_satisfaction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<int> submittedAt = GeneratedColumn<int>(
    'submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    qProductivity,
    qFocus,
    qMentalTired,
    qPhysicalEnergy,
    qDistracted,
    qUsedWhitelisted,
    qUsedAppsJson,
    qSatisfaction,
    notes,
    submittedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_feedbacks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionFeedback> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('q_productivity')) {
      context.handle(
        _qProductivityMeta,
        qProductivity.isAcceptableOrUnknown(
          data['q_productivity']!,
          _qProductivityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qProductivityMeta);
    }
    if (data.containsKey('q_focus')) {
      context.handle(
        _qFocusMeta,
        qFocus.isAcceptableOrUnknown(data['q_focus']!, _qFocusMeta),
      );
    } else if (isInserting) {
      context.missing(_qFocusMeta);
    }
    if (data.containsKey('q_mental_tired')) {
      context.handle(
        _qMentalTiredMeta,
        qMentalTired.isAcceptableOrUnknown(
          data['q_mental_tired']!,
          _qMentalTiredMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qMentalTiredMeta);
    }
    if (data.containsKey('q_physical_energy')) {
      context.handle(
        _qPhysicalEnergyMeta,
        qPhysicalEnergy.isAcceptableOrUnknown(
          data['q_physical_energy']!,
          _qPhysicalEnergyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qPhysicalEnergyMeta);
    }
    if (data.containsKey('q_distracted')) {
      context.handle(
        _qDistractedMeta,
        qDistracted.isAcceptableOrUnknown(
          data['q_distracted']!,
          _qDistractedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qDistractedMeta);
    }
    if (data.containsKey('q_used_whitelisted')) {
      context.handle(
        _qUsedWhitelistedMeta,
        qUsedWhitelisted.isAcceptableOrUnknown(
          data['q_used_whitelisted']!,
          _qUsedWhitelistedMeta,
        ),
      );
    }
    if (data.containsKey('q_used_apps_json')) {
      context.handle(
        _qUsedAppsJsonMeta,
        qUsedAppsJson.isAcceptableOrUnknown(
          data['q_used_apps_json']!,
          _qUsedAppsJsonMeta,
        ),
      );
    }
    if (data.containsKey('q_satisfaction')) {
      context.handle(
        _qSatisfactionMeta,
        qSatisfaction.isAcceptableOrUnknown(
          data['q_satisfaction']!,
          _qSatisfactionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qSatisfactionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionFeedback map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionFeedback(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      qProductivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_productivity'],
      )!,
      qFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_focus'],
      )!,
      qMentalTired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_mental_tired'],
      )!,
      qPhysicalEnergy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_physical_energy'],
      )!,
      qDistracted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_distracted'],
      )!,
      qUsedWhitelisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}q_used_whitelisted'],
      )!,
      qUsedAppsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}q_used_apps_json'],
      ),
      qSatisfaction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}q_satisfaction'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitted_at'],
      )!,
    );
  }

  @override
  $SessionFeedbacksTable createAlias(String alias) {
    return $SessionFeedbacksTable(attachedDatabase, alias);
  }
}

class SessionFeedback extends DataClass implements Insertable<SessionFeedback> {
  final String id;
  final String sessionId;
  final int qProductivity;
  final int qFocus;
  final int qMentalTired;
  final int qPhysicalEnergy;
  final int qDistracted;
  final bool qUsedWhitelisted;
  final String? qUsedAppsJson;
  final int qSatisfaction;
  final String? notes;
  final int submittedAt;
  const SessionFeedback({
    required this.id,
    required this.sessionId,
    required this.qProductivity,
    required this.qFocus,
    required this.qMentalTired,
    required this.qPhysicalEnergy,
    required this.qDistracted,
    required this.qUsedWhitelisted,
    this.qUsedAppsJson,
    required this.qSatisfaction,
    this.notes,
    required this.submittedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['q_productivity'] = Variable<int>(qProductivity);
    map['q_focus'] = Variable<int>(qFocus);
    map['q_mental_tired'] = Variable<int>(qMentalTired);
    map['q_physical_energy'] = Variable<int>(qPhysicalEnergy);
    map['q_distracted'] = Variable<int>(qDistracted);
    map['q_used_whitelisted'] = Variable<bool>(qUsedWhitelisted);
    if (!nullToAbsent || qUsedAppsJson != null) {
      map['q_used_apps_json'] = Variable<String>(qUsedAppsJson);
    }
    map['q_satisfaction'] = Variable<int>(qSatisfaction);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['submitted_at'] = Variable<int>(submittedAt);
    return map;
  }

  SessionFeedbacksCompanion toCompanion(bool nullToAbsent) {
    return SessionFeedbacksCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      qProductivity: Value(qProductivity),
      qFocus: Value(qFocus),
      qMentalTired: Value(qMentalTired),
      qPhysicalEnergy: Value(qPhysicalEnergy),
      qDistracted: Value(qDistracted),
      qUsedWhitelisted: Value(qUsedWhitelisted),
      qUsedAppsJson: qUsedAppsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(qUsedAppsJson),
      qSatisfaction: Value(qSatisfaction),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      submittedAt: Value(submittedAt),
    );
  }

  factory SessionFeedback.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionFeedback(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      qProductivity: serializer.fromJson<int>(json['qProductivity']),
      qFocus: serializer.fromJson<int>(json['qFocus']),
      qMentalTired: serializer.fromJson<int>(json['qMentalTired']),
      qPhysicalEnergy: serializer.fromJson<int>(json['qPhysicalEnergy']),
      qDistracted: serializer.fromJson<int>(json['qDistracted']),
      qUsedWhitelisted: serializer.fromJson<bool>(json['qUsedWhitelisted']),
      qUsedAppsJson: serializer.fromJson<String?>(json['qUsedAppsJson']),
      qSatisfaction: serializer.fromJson<int>(json['qSatisfaction']),
      notes: serializer.fromJson<String?>(json['notes']),
      submittedAt: serializer.fromJson<int>(json['submittedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'qProductivity': serializer.toJson<int>(qProductivity),
      'qFocus': serializer.toJson<int>(qFocus),
      'qMentalTired': serializer.toJson<int>(qMentalTired),
      'qPhysicalEnergy': serializer.toJson<int>(qPhysicalEnergy),
      'qDistracted': serializer.toJson<int>(qDistracted),
      'qUsedWhitelisted': serializer.toJson<bool>(qUsedWhitelisted),
      'qUsedAppsJson': serializer.toJson<String?>(qUsedAppsJson),
      'qSatisfaction': serializer.toJson<int>(qSatisfaction),
      'notes': serializer.toJson<String?>(notes),
      'submittedAt': serializer.toJson<int>(submittedAt),
    };
  }

  SessionFeedback copyWith({
    String? id,
    String? sessionId,
    int? qProductivity,
    int? qFocus,
    int? qMentalTired,
    int? qPhysicalEnergy,
    int? qDistracted,
    bool? qUsedWhitelisted,
    Value<String?> qUsedAppsJson = const Value.absent(),
    int? qSatisfaction,
    Value<String?> notes = const Value.absent(),
    int? submittedAt,
  }) => SessionFeedback(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    qProductivity: qProductivity ?? this.qProductivity,
    qFocus: qFocus ?? this.qFocus,
    qMentalTired: qMentalTired ?? this.qMentalTired,
    qPhysicalEnergy: qPhysicalEnergy ?? this.qPhysicalEnergy,
    qDistracted: qDistracted ?? this.qDistracted,
    qUsedWhitelisted: qUsedWhitelisted ?? this.qUsedWhitelisted,
    qUsedAppsJson: qUsedAppsJson.present
        ? qUsedAppsJson.value
        : this.qUsedAppsJson,
    qSatisfaction: qSatisfaction ?? this.qSatisfaction,
    notes: notes.present ? notes.value : this.notes,
    submittedAt: submittedAt ?? this.submittedAt,
  );
  SessionFeedback copyWithCompanion(SessionFeedbacksCompanion data) {
    return SessionFeedback(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      qProductivity: data.qProductivity.present
          ? data.qProductivity.value
          : this.qProductivity,
      qFocus: data.qFocus.present ? data.qFocus.value : this.qFocus,
      qMentalTired: data.qMentalTired.present
          ? data.qMentalTired.value
          : this.qMentalTired,
      qPhysicalEnergy: data.qPhysicalEnergy.present
          ? data.qPhysicalEnergy.value
          : this.qPhysicalEnergy,
      qDistracted: data.qDistracted.present
          ? data.qDistracted.value
          : this.qDistracted,
      qUsedWhitelisted: data.qUsedWhitelisted.present
          ? data.qUsedWhitelisted.value
          : this.qUsedWhitelisted,
      qUsedAppsJson: data.qUsedAppsJson.present
          ? data.qUsedAppsJson.value
          : this.qUsedAppsJson,
      qSatisfaction: data.qSatisfaction.present
          ? data.qSatisfaction.value
          : this.qSatisfaction,
      notes: data.notes.present ? data.notes.value : this.notes,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionFeedback(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('qProductivity: $qProductivity, ')
          ..write('qFocus: $qFocus, ')
          ..write('qMentalTired: $qMentalTired, ')
          ..write('qPhysicalEnergy: $qPhysicalEnergy, ')
          ..write('qDistracted: $qDistracted, ')
          ..write('qUsedWhitelisted: $qUsedWhitelisted, ')
          ..write('qUsedAppsJson: $qUsedAppsJson, ')
          ..write('qSatisfaction: $qSatisfaction, ')
          ..write('notes: $notes, ')
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    qProductivity,
    qFocus,
    qMentalTired,
    qPhysicalEnergy,
    qDistracted,
    qUsedWhitelisted,
    qUsedAppsJson,
    qSatisfaction,
    notes,
    submittedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionFeedback &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.qProductivity == this.qProductivity &&
          other.qFocus == this.qFocus &&
          other.qMentalTired == this.qMentalTired &&
          other.qPhysicalEnergy == this.qPhysicalEnergy &&
          other.qDistracted == this.qDistracted &&
          other.qUsedWhitelisted == this.qUsedWhitelisted &&
          other.qUsedAppsJson == this.qUsedAppsJson &&
          other.qSatisfaction == this.qSatisfaction &&
          other.notes == this.notes &&
          other.submittedAt == this.submittedAt);
}

class SessionFeedbacksCompanion extends UpdateCompanion<SessionFeedback> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> qProductivity;
  final Value<int> qFocus;
  final Value<int> qMentalTired;
  final Value<int> qPhysicalEnergy;
  final Value<int> qDistracted;
  final Value<bool> qUsedWhitelisted;
  final Value<String?> qUsedAppsJson;
  final Value<int> qSatisfaction;
  final Value<String?> notes;
  final Value<int> submittedAt;
  final Value<int> rowid;
  const SessionFeedbacksCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.qProductivity = const Value.absent(),
    this.qFocus = const Value.absent(),
    this.qMentalTired = const Value.absent(),
    this.qPhysicalEnergy = const Value.absent(),
    this.qDistracted = const Value.absent(),
    this.qUsedWhitelisted = const Value.absent(),
    this.qUsedAppsJson = const Value.absent(),
    this.qSatisfaction = const Value.absent(),
    this.notes = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionFeedbacksCompanion.insert({
    required String id,
    required String sessionId,
    required int qProductivity,
    required int qFocus,
    required int qMentalTired,
    required int qPhysicalEnergy,
    required int qDistracted,
    this.qUsedWhitelisted = const Value.absent(),
    this.qUsedAppsJson = const Value.absent(),
    required int qSatisfaction,
    this.notes = const Value.absent(),
    required int submittedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       qProductivity = Value(qProductivity),
       qFocus = Value(qFocus),
       qMentalTired = Value(qMentalTired),
       qPhysicalEnergy = Value(qPhysicalEnergy),
       qDistracted = Value(qDistracted),
       qSatisfaction = Value(qSatisfaction),
       submittedAt = Value(submittedAt);
  static Insertable<SessionFeedback> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? qProductivity,
    Expression<int>? qFocus,
    Expression<int>? qMentalTired,
    Expression<int>? qPhysicalEnergy,
    Expression<int>? qDistracted,
    Expression<bool>? qUsedWhitelisted,
    Expression<String>? qUsedAppsJson,
    Expression<int>? qSatisfaction,
    Expression<String>? notes,
    Expression<int>? submittedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (qProductivity != null) 'q_productivity': qProductivity,
      if (qFocus != null) 'q_focus': qFocus,
      if (qMentalTired != null) 'q_mental_tired': qMentalTired,
      if (qPhysicalEnergy != null) 'q_physical_energy': qPhysicalEnergy,
      if (qDistracted != null) 'q_distracted': qDistracted,
      if (qUsedWhitelisted != null) 'q_used_whitelisted': qUsedWhitelisted,
      if (qUsedAppsJson != null) 'q_used_apps_json': qUsedAppsJson,
      if (qSatisfaction != null) 'q_satisfaction': qSatisfaction,
      if (notes != null) 'notes': notes,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionFeedbacksCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? qProductivity,
    Value<int>? qFocus,
    Value<int>? qMentalTired,
    Value<int>? qPhysicalEnergy,
    Value<int>? qDistracted,
    Value<bool>? qUsedWhitelisted,
    Value<String?>? qUsedAppsJson,
    Value<int>? qSatisfaction,
    Value<String?>? notes,
    Value<int>? submittedAt,
    Value<int>? rowid,
  }) {
    return SessionFeedbacksCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      qProductivity: qProductivity ?? this.qProductivity,
      qFocus: qFocus ?? this.qFocus,
      qMentalTired: qMentalTired ?? this.qMentalTired,
      qPhysicalEnergy: qPhysicalEnergy ?? this.qPhysicalEnergy,
      qDistracted: qDistracted ?? this.qDistracted,
      qUsedWhitelisted: qUsedWhitelisted ?? this.qUsedWhitelisted,
      qUsedAppsJson: qUsedAppsJson ?? this.qUsedAppsJson,
      qSatisfaction: qSatisfaction ?? this.qSatisfaction,
      notes: notes ?? this.notes,
      submittedAt: submittedAt ?? this.submittedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (qProductivity.present) {
      map['q_productivity'] = Variable<int>(qProductivity.value);
    }
    if (qFocus.present) {
      map['q_focus'] = Variable<int>(qFocus.value);
    }
    if (qMentalTired.present) {
      map['q_mental_tired'] = Variable<int>(qMentalTired.value);
    }
    if (qPhysicalEnergy.present) {
      map['q_physical_energy'] = Variable<int>(qPhysicalEnergy.value);
    }
    if (qDistracted.present) {
      map['q_distracted'] = Variable<int>(qDistracted.value);
    }
    if (qUsedWhitelisted.present) {
      map['q_used_whitelisted'] = Variable<bool>(qUsedWhitelisted.value);
    }
    if (qUsedAppsJson.present) {
      map['q_used_apps_json'] = Variable<String>(qUsedAppsJson.value);
    }
    if (qSatisfaction.present) {
      map['q_satisfaction'] = Variable<int>(qSatisfaction.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<int>(submittedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionFeedbacksCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('qProductivity: $qProductivity, ')
          ..write('qFocus: $qFocus, ')
          ..write('qMentalTired: $qMentalTired, ')
          ..write('qPhysicalEnergy: $qPhysicalEnergy, ')
          ..write('qDistracted: $qDistracted, ')
          ..write('qUsedWhitelisted: $qUsedWhitelisted, ')
          ..write('qUsedAppsJson: $qUsedAppsJson, ')
          ..write('qSatisfaction: $qSatisfaction, ')
          ..write('notes: $notes, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlockAttemptsTable extends BlockAttempts
    with TableInfo<$BlockAttemptsTable, BlockAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _blockedPackageMeta = const VerificationMeta(
    'blockedPackage',
  );
  @override
  late final GeneratedColumn<String> blockedPackage = GeneratedColumn<String>(
    'blocked_package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptTimeMeta = const VerificationMeta(
    'attemptTime',
  );
  @override
  late final GeneratedColumn<int> attemptTime = GeneratedColumn<int>(
    'attempt_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    blockedPackage,
    attemptTime,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('blocked_package')) {
      context.handle(
        _blockedPackageMeta,
        blockedPackage.isAcceptableOrUnknown(
          data['blocked_package']!,
          _blockedPackageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_blockedPackageMeta);
    }
    if (data.containsKey('attempt_time')) {
      context.handle(
        _attemptTimeMeta,
        attemptTime.isAcceptableOrUnknown(
          data['attempt_time']!,
          _attemptTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptTimeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      blockedPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_package'],
      )!,
      attemptTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_time'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $BlockAttemptsTable createAlias(String alias) {
    return $BlockAttemptsTable(attachedDatabase, alias);
  }
}

class BlockAttempt extends DataClass implements Insertable<BlockAttempt> {
  final String id;
  final String sessionId;
  final String blockedPackage;
  final int attemptTime;
  final String? reason;
  const BlockAttempt({
    required this.id,
    required this.sessionId,
    required this.blockedPackage,
    required this.attemptTime,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['blocked_package'] = Variable<String>(blockedPackage);
    map['attempt_time'] = Variable<int>(attemptTime);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  BlockAttemptsCompanion toCompanion(bool nullToAbsent) {
    return BlockAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      blockedPackage: Value(blockedPackage),
      attemptTime: Value(attemptTime),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory BlockAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockAttempt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      blockedPackage: serializer.fromJson<String>(json['blockedPackage']),
      attemptTime: serializer.fromJson<int>(json['attemptTime']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'blockedPackage': serializer.toJson<String>(blockedPackage),
      'attemptTime': serializer.toJson<int>(attemptTime),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  BlockAttempt copyWith({
    String? id,
    String? sessionId,
    String? blockedPackage,
    int? attemptTime,
    Value<String?> reason = const Value.absent(),
  }) => BlockAttempt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    blockedPackage: blockedPackage ?? this.blockedPackage,
    attemptTime: attemptTime ?? this.attemptTime,
    reason: reason.present ? reason.value : this.reason,
  );
  BlockAttempt copyWithCompanion(BlockAttemptsCompanion data) {
    return BlockAttempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      blockedPackage: data.blockedPackage.present
          ? data.blockedPackage.value
          : this.blockedPackage,
      attemptTime: data.attemptTime.present
          ? data.attemptTime.value
          : this.attemptTime,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockAttempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockedPackage: $blockedPackage, ')
          ..write('attemptTime: $attemptTime, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, blockedPackage, attemptTime, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockAttempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.blockedPackage == this.blockedPackage &&
          other.attemptTime == this.attemptTime &&
          other.reason == this.reason);
}

class BlockAttemptsCompanion extends UpdateCompanion<BlockAttempt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> blockedPackage;
  final Value<int> attemptTime;
  final Value<String?> reason;
  final Value<int> rowid;
  const BlockAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.blockedPackage = const Value.absent(),
    this.attemptTime = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlockAttemptsCompanion.insert({
    required String id,
    required String sessionId,
    required String blockedPackage,
    required int attemptTime,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       blockedPackage = Value(blockedPackage),
       attemptTime = Value(attemptTime);
  static Insertable<BlockAttempt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? blockedPackage,
    Expression<int>? attemptTime,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (blockedPackage != null) 'blocked_package': blockedPackage,
      if (attemptTime != null) 'attempt_time': attemptTime,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlockAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? blockedPackage,
    Value<int>? attemptTime,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return BlockAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      blockedPackage: blockedPackage ?? this.blockedPackage,
      attemptTime: attemptTime ?? this.attemptTime,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (blockedPackage.present) {
      map['blocked_package'] = Variable<String>(blockedPackage.value);
    }
    if (attemptTime.present) {
      map['attempt_time'] = Variable<int>(attemptTime.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockedPackage: $blockedPackage, ')
          ..write('attemptTime: $attemptTime, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AppWhitelistsTable appWhitelists = $AppWhitelistsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $SessionFeedbacksTable sessionFeedbacks = $SessionFeedbacksTable(
    this,
  );
  late final $BlockAttemptsTable blockAttempts = $BlockAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    appWhitelists,
    studySessions,
    sessionFeedbacks,
    blockAttempts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_feedbacks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('block_attempts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String wakeTime,
      required String sleepTime,
      Value<String?> workStartTime,
      Value<String?> workEndTime,
      Value<bool> drinksCaffeine,
      Value<String?> caffeineTiming,
      Value<String?> caffeineTime,
      Value<String?> chronotype,
      Value<String> studyDays,
      Value<int?> onboardingCompletedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> wakeTime,
      Value<String> sleepTime,
      Value<String?> workStartTime,
      Value<String?> workEndTime,
      Value<bool> drinksCaffeine,
      Value<String?> caffeineTiming,
      Value<String?> caffeineTime,
      Value<String?> chronotype,
      Value<String> studyDays,
      Value<int?> onboardingCompletedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workStartTime => $composableBuilder(
    column: $table.workStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workEndTime => $composableBuilder(
    column: $table.workEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get drinksCaffeine => $composableBuilder(
    column: $table.drinksCaffeine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caffeineTiming => $composableBuilder(
    column: $table.caffeineTiming,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caffeineTime => $composableBuilder(
    column: $table.caffeineTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chronotype => $composableBuilder(
    column: $table.chronotype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studyDays => $composableBuilder(
    column: $table.studyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workStartTime => $composableBuilder(
    column: $table.workStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workEndTime => $composableBuilder(
    column: $table.workEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get drinksCaffeine => $composableBuilder(
    column: $table.drinksCaffeine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caffeineTiming => $composableBuilder(
    column: $table.caffeineTiming,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caffeineTime => $composableBuilder(
    column: $table.caffeineTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chronotype => $composableBuilder(
    column: $table.chronotype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studyDays => $composableBuilder(
    column: $table.studyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<String> get sleepTime =>
      $composableBuilder(column: $table.sleepTime, builder: (column) => column);

  GeneratedColumn<String> get workStartTime => $composableBuilder(
    column: $table.workStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workEndTime => $composableBuilder(
    column: $table.workEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get drinksCaffeine => $composableBuilder(
    column: $table.drinksCaffeine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caffeineTiming => $composableBuilder(
    column: $table.caffeineTiming,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caffeineTime => $composableBuilder(
    column: $table.caffeineTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chronotype => $composableBuilder(
    column: $table.chronotype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studyDays =>
      $composableBuilder(column: $table.studyDays, builder: (column) => column);

  GeneratedColumn<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> wakeTime = const Value.absent(),
                Value<String> sleepTime = const Value.absent(),
                Value<String?> workStartTime = const Value.absent(),
                Value<String?> workEndTime = const Value.absent(),
                Value<bool> drinksCaffeine = const Value.absent(),
                Value<String?> caffeineTiming = const Value.absent(),
                Value<String?> caffeineTime = const Value.absent(),
                Value<String?> chronotype = const Value.absent(),
                Value<String> studyDays = const Value.absent(),
                Value<int?> onboardingCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                wakeTime: wakeTime,
                sleepTime: sleepTime,
                workStartTime: workStartTime,
                workEndTime: workEndTime,
                drinksCaffeine: drinksCaffeine,
                caffeineTiming: caffeineTiming,
                caffeineTime: caffeineTime,
                chronotype: chronotype,
                studyDays: studyDays,
                onboardingCompletedAt: onboardingCompletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String wakeTime,
                required String sleepTime,
                Value<String?> workStartTime = const Value.absent(),
                Value<String?> workEndTime = const Value.absent(),
                Value<bool> drinksCaffeine = const Value.absent(),
                Value<String?> caffeineTiming = const Value.absent(),
                Value<String?> caffeineTime = const Value.absent(),
                Value<String?> chronotype = const Value.absent(),
                Value<String> studyDays = const Value.absent(),
                Value<int?> onboardingCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                wakeTime: wakeTime,
                sleepTime: sleepTime,
                workStartTime: workStartTime,
                workEndTime: workEndTime,
                drinksCaffeine: drinksCaffeine,
                caffeineTiming: caffeineTiming,
                caffeineTime: caffeineTime,
                chronotype: chronotype,
                studyDays: studyDays,
                onboardingCompletedAt: onboardingCompletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$AppWhitelistsTableCreateCompanionBuilder =
    AppWhitelistsCompanion Function({
      required String packageName,
      required String appName,
      Value<String?> iconPath,
      Value<int> rowid,
    });
typedef $$AppWhitelistsTableUpdateCompanionBuilder =
    AppWhitelistsCompanion Function({
      Value<String> packageName,
      Value<String> appName,
      Value<String?> iconPath,
      Value<int> rowid,
    });

class $$AppWhitelistsTableFilterComposer
    extends Composer<_$AppDatabase, $AppWhitelistsTable> {
  $$AppWhitelistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppWhitelistsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppWhitelistsTable> {
  $$AppWhitelistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppWhitelistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppWhitelistsTable> {
  $$AppWhitelistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);
}

class $$AppWhitelistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppWhitelistsTable,
          AppWhitelist,
          $$AppWhitelistsTableFilterComposer,
          $$AppWhitelistsTableOrderingComposer,
          $$AppWhitelistsTableAnnotationComposer,
          $$AppWhitelistsTableCreateCompanionBuilder,
          $$AppWhitelistsTableUpdateCompanionBuilder,
          (
            AppWhitelist,
            BaseReferences<_$AppDatabase, $AppWhitelistsTable, AppWhitelist>,
          ),
          AppWhitelist,
          PrefetchHooks Function()
        > {
  $$AppWhitelistsTableTableManager(_$AppDatabase db, $AppWhitelistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppWhitelistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppWhitelistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppWhitelistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppWhitelistsCompanion(
                packageName: packageName,
                appName: appName,
                iconPath: iconPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageName,
                required String appName,
                Value<String?> iconPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppWhitelistsCompanion.insert(
                packageName: packageName,
                appName: appName,
                iconPath: iconPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppWhitelistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppWhitelistsTable,
      AppWhitelist,
      $$AppWhitelistsTableFilterComposer,
      $$AppWhitelistsTableOrderingComposer,
      $$AppWhitelistsTableAnnotationComposer,
      $$AppWhitelistsTableCreateCompanionBuilder,
      $$AppWhitelistsTableUpdateCompanionBuilder,
      (
        AppWhitelist,
        BaseReferences<_$AppDatabase, $AppWhitelistsTable, AppWhitelist>,
      ),
      AppWhitelist,
      PrefetchHooks Function()
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      required String id,
      required int startTime,
      required int endTime,
      required double durationMinutes,
      Value<bool> endedEarly,
      required int dayOfWeek,
      required int hourOfDay,
      required String timeBlock,
      Value<int> attemptsCount,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<String> id,
      Value<int> startTime,
      Value<int> endTime,
      Value<double> durationMinutes,
      Value<bool> endedEarly,
      Value<int> dayOfWeek,
      Value<int> hourOfDay,
      Value<String> timeBlock,
      Value<int> attemptsCount,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$StudySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession> {
  $$StudySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionFeedbacksTable, List<SessionFeedback>>
  _sessionFeedbacksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionFeedbacks,
    aliasName: $_aliasNameGenerator(
      db.studySessions.id,
      db.sessionFeedbacks.sessionId,
    ),
  );

  $$SessionFeedbacksTableProcessedTableManager get sessionFeedbacksRefs {
    final manager = $$SessionFeedbacksTableTableManager(
      $_db,
      $_db.sessionFeedbacks,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionFeedbacksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BlockAttemptsTable, List<BlockAttempt>>
  _blockAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.blockAttempts,
    aliasName: $_aliasNameGenerator(
      db.studySessions.id,
      db.blockAttempts.sessionId,
    ),
  );

  $$BlockAttemptsTableProcessedTableManager get blockAttemptsRefs {
    final manager = $$BlockAttemptsTableTableManager(
      $_db,
      $_db.blockAttempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_blockAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourOfDay => $composableBuilder(
    column: $table.hourOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeBlock => $composableBuilder(
    column: $table.timeBlock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionFeedbacksRefs(
    Expression<bool> Function($$SessionFeedbacksTableFilterComposer f) f,
  ) {
    final $$SessionFeedbacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionFeedbacks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionFeedbacksTableFilterComposer(
            $db: $db,
            $table: $db.sessionFeedbacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> blockAttemptsRefs(
    Expression<bool> Function($$BlockAttemptsTableFilterComposer f) f,
  ) {
    final $$BlockAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blockAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlockAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.blockAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourOfDay => $composableBuilder(
    column: $table.hourOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeBlock => $composableBuilder(
    column: $table.timeBlock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get hourOfDay =>
      $composableBuilder(column: $table.hourOfDay, builder: (column) => column);

  GeneratedColumn<String> get timeBlock =>
      $composableBuilder(column: $table.timeBlock, builder: (column) => column);

  GeneratedColumn<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sessionFeedbacksRefs<T extends Object>(
    Expression<T> Function($$SessionFeedbacksTableAnnotationComposer a) f,
  ) {
    final $$SessionFeedbacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionFeedbacks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionFeedbacksTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionFeedbacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> blockAttemptsRefs<T extends Object>(
    Expression<T> Function($$BlockAttemptsTableAnnotationComposer a) f,
  ) {
    final $$BlockAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blockAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlockAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.blockAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (StudySession, $$StudySessionsTableReferences),
          StudySession,
          PrefetchHooks Function({
            bool sessionFeedbacksRefs,
            bool blockAttemptsRefs,
          })
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<double> durationMinutes = const Value.absent(),
                Value<bool> endedEarly = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<int> hourOfDay = const Value.absent(),
                Value<String> timeBlock = const Value.absent(),
                Value<int> attemptsCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                endedEarly: endedEarly,
                dayOfWeek: dayOfWeek,
                hourOfDay: hourOfDay,
                timeBlock: timeBlock,
                attemptsCount: attemptsCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startTime,
                required int endTime,
                required double durationMinutes,
                Value<bool> endedEarly = const Value.absent(),
                required int dayOfWeek,
                required int hourOfDay,
                required String timeBlock,
                Value<int> attemptsCount = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                endedEarly: endedEarly,
                dayOfWeek: dayOfWeek,
                hourOfDay: hourOfDay,
                timeBlock: timeBlock,
                attemptsCount: attemptsCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionFeedbacksRefs = false, blockAttemptsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionFeedbacksRefs) db.sessionFeedbacks,
                    if (blockAttemptsRefs) db.blockAttempts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionFeedbacksRefs)
                        await $_getPrefetchedData<
                          StudySession,
                          $StudySessionsTable,
                          SessionFeedback
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionsTableReferences
                              ._sessionFeedbacksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionFeedbacksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (blockAttemptsRefs)
                        await $_getPrefetchedData<
                          StudySession,
                          $StudySessionsTable,
                          BlockAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionsTableReferences
                              ._blockAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).blockAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (StudySession, $$StudySessionsTableReferences),
      StudySession,
      PrefetchHooks Function({
        bool sessionFeedbacksRefs,
        bool blockAttemptsRefs,
      })
    >;
typedef $$SessionFeedbacksTableCreateCompanionBuilder =
    SessionFeedbacksCompanion Function({
      required String id,
      required String sessionId,
      required int qProductivity,
      required int qFocus,
      required int qMentalTired,
      required int qPhysicalEnergy,
      required int qDistracted,
      Value<bool> qUsedWhitelisted,
      Value<String?> qUsedAppsJson,
      required int qSatisfaction,
      Value<String?> notes,
      required int submittedAt,
      Value<int> rowid,
    });
typedef $$SessionFeedbacksTableUpdateCompanionBuilder =
    SessionFeedbacksCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> qProductivity,
      Value<int> qFocus,
      Value<int> qMentalTired,
      Value<int> qPhysicalEnergy,
      Value<int> qDistracted,
      Value<bool> qUsedWhitelisted,
      Value<String?> qUsedAppsJson,
      Value<int> qSatisfaction,
      Value<String?> notes,
      Value<int> submittedAt,
      Value<int> rowid,
    });

final class $$SessionFeedbacksTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionFeedbacksTable, SessionFeedback> {
  $$SessionFeedbacksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
        $_aliasNameGenerator(
          db.sessionFeedbacks.sessionId,
          db.studySessions.id,
        ),
      );

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionFeedbacksTableFilterComposer
    extends Composer<_$AppDatabase, $SessionFeedbacksTable> {
  $$SessionFeedbacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qProductivity => $composableBuilder(
    column: $table.qProductivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qFocus => $composableBuilder(
    column: $table.qFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qMentalTired => $composableBuilder(
    column: $table.qMentalTired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qPhysicalEnergy => $composableBuilder(
    column: $table.qPhysicalEnergy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qDistracted => $composableBuilder(
    column: $table.qDistracted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get qUsedWhitelisted => $composableBuilder(
    column: $table.qUsedWhitelisted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qUsedAppsJson => $composableBuilder(
    column: $table.qUsedAppsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qSatisfaction => $composableBuilder(
    column: $table.qSatisfaction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionFeedbacksTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionFeedbacksTable> {
  $$SessionFeedbacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qProductivity => $composableBuilder(
    column: $table.qProductivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qFocus => $composableBuilder(
    column: $table.qFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qMentalTired => $composableBuilder(
    column: $table.qMentalTired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qPhysicalEnergy => $composableBuilder(
    column: $table.qPhysicalEnergy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qDistracted => $composableBuilder(
    column: $table.qDistracted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get qUsedWhitelisted => $composableBuilder(
    column: $table.qUsedWhitelisted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qUsedAppsJson => $composableBuilder(
    column: $table.qUsedAppsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qSatisfaction => $composableBuilder(
    column: $table.qSatisfaction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionFeedbacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionFeedbacksTable> {
  $$SessionFeedbacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get qProductivity => $composableBuilder(
    column: $table.qProductivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qFocus =>
      $composableBuilder(column: $table.qFocus, builder: (column) => column);

  GeneratedColumn<int> get qMentalTired => $composableBuilder(
    column: $table.qMentalTired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qPhysicalEnergy => $composableBuilder(
    column: $table.qPhysicalEnergy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qDistracted => $composableBuilder(
    column: $table.qDistracted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get qUsedWhitelisted => $composableBuilder(
    column: $table.qUsedWhitelisted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qUsedAppsJson => $composableBuilder(
    column: $table.qUsedAppsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qSatisfaction => $composableBuilder(
    column: $table.qSatisfaction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionFeedbacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionFeedbacksTable,
          SessionFeedback,
          $$SessionFeedbacksTableFilterComposer,
          $$SessionFeedbacksTableOrderingComposer,
          $$SessionFeedbacksTableAnnotationComposer,
          $$SessionFeedbacksTableCreateCompanionBuilder,
          $$SessionFeedbacksTableUpdateCompanionBuilder,
          (SessionFeedback, $$SessionFeedbacksTableReferences),
          SessionFeedback,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionFeedbacksTableTableManager(
    _$AppDatabase db,
    $SessionFeedbacksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionFeedbacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionFeedbacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionFeedbacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> qProductivity = const Value.absent(),
                Value<int> qFocus = const Value.absent(),
                Value<int> qMentalTired = const Value.absent(),
                Value<int> qPhysicalEnergy = const Value.absent(),
                Value<int> qDistracted = const Value.absent(),
                Value<bool> qUsedWhitelisted = const Value.absent(),
                Value<String?> qUsedAppsJson = const Value.absent(),
                Value<int> qSatisfaction = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> submittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionFeedbacksCompanion(
                id: id,
                sessionId: sessionId,
                qProductivity: qProductivity,
                qFocus: qFocus,
                qMentalTired: qMentalTired,
                qPhysicalEnergy: qPhysicalEnergy,
                qDistracted: qDistracted,
                qUsedWhitelisted: qUsedWhitelisted,
                qUsedAppsJson: qUsedAppsJson,
                qSatisfaction: qSatisfaction,
                notes: notes,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int qProductivity,
                required int qFocus,
                required int qMentalTired,
                required int qPhysicalEnergy,
                required int qDistracted,
                Value<bool> qUsedWhitelisted = const Value.absent(),
                Value<String?> qUsedAppsJson = const Value.absent(),
                required int qSatisfaction,
                Value<String?> notes = const Value.absent(),
                required int submittedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionFeedbacksCompanion.insert(
                id: id,
                sessionId: sessionId,
                qProductivity: qProductivity,
                qFocus: qFocus,
                qMentalTired: qMentalTired,
                qPhysicalEnergy: qPhysicalEnergy,
                qDistracted: qDistracted,
                qUsedWhitelisted: qUsedWhitelisted,
                qUsedAppsJson: qUsedAppsJson,
                qSatisfaction: qSatisfaction,
                notes: notes,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionFeedbacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$SessionFeedbacksTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$SessionFeedbacksTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionFeedbacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionFeedbacksTable,
      SessionFeedback,
      $$SessionFeedbacksTableFilterComposer,
      $$SessionFeedbacksTableOrderingComposer,
      $$SessionFeedbacksTableAnnotationComposer,
      $$SessionFeedbacksTableCreateCompanionBuilder,
      $$SessionFeedbacksTableUpdateCompanionBuilder,
      (SessionFeedback, $$SessionFeedbacksTableReferences),
      SessionFeedback,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$BlockAttemptsTableCreateCompanionBuilder =
    BlockAttemptsCompanion Function({
      required String id,
      required String sessionId,
      required String blockedPackage,
      required int attemptTime,
      Value<String?> reason,
      Value<int> rowid,
    });
typedef $$BlockAttemptsTableUpdateCompanionBuilder =
    BlockAttemptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> blockedPackage,
      Value<int> attemptTime,
      Value<String?> reason,
      Value<int> rowid,
    });

final class $$BlockAttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $BlockAttemptsTable, BlockAttempt> {
  $$BlockAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
        $_aliasNameGenerator(db.blockAttempts.sessionId, db.studySessions.id),
      );

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BlockAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedPackage => $composableBuilder(
    column: $table.blockedPackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedPackage => $composableBuilder(
    column: $table.blockedPackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get blockedPackage => $composableBuilder(
    column: $table.blockedPackage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockAttemptsTable,
          BlockAttempt,
          $$BlockAttemptsTableFilterComposer,
          $$BlockAttemptsTableOrderingComposer,
          $$BlockAttemptsTableAnnotationComposer,
          $$BlockAttemptsTableCreateCompanionBuilder,
          $$BlockAttemptsTableUpdateCompanionBuilder,
          (BlockAttempt, $$BlockAttemptsTableReferences),
          BlockAttempt,
          PrefetchHooks Function({bool sessionId})
        > {
  $$BlockAttemptsTableTableManager(_$AppDatabase db, $BlockAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> blockedPackage = const Value.absent(),
                Value<int> attemptTime = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                blockedPackage: blockedPackage,
                attemptTime: attemptTime,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String blockedPackage,
                required int attemptTime,
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                blockedPackage: blockedPackage,
                attemptTime: attemptTime,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BlockAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$BlockAttemptsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$BlockAttemptsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BlockAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockAttemptsTable,
      BlockAttempt,
      $$BlockAttemptsTableFilterComposer,
      $$BlockAttemptsTableOrderingComposer,
      $$BlockAttemptsTableAnnotationComposer,
      $$BlockAttemptsTableCreateCompanionBuilder,
      $$BlockAttemptsTableUpdateCompanionBuilder,
      (BlockAttempt, $$BlockAttemptsTableReferences),
      BlockAttempt,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AppWhitelistsTableTableManager get appWhitelists =>
      $$AppWhitelistsTableTableManager(_db, _db.appWhitelists);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$SessionFeedbacksTableTableManager get sessionFeedbacks =>
      $$SessionFeedbacksTableTableManager(_db, _db.sessionFeedbacks);
  $$BlockAttemptsTableTableManager get blockAttempts =>
      $$BlockAttemptsTableTableManager(_db, _db.blockAttempts);
}
