import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/database/database.dart';
import 'package:study_app/providers.dart';

class OnboardingState {
  OnboardingState({
    this.step = 0,
    this.wakeTime,
    this.sleepTime,
    this.workStartTime,
    this.workEndTime,
    this.drinksCaffeine = false,
    this.caffeineTiming,
    this.caffeineTime,
    this.chronotype,
    this.studyDays = const {},
    this.selectedPackages = const {},
  });

  final int step;
  final TimeOfDay? wakeTime;
  final TimeOfDay? sleepTime;
  final TimeOfDay? workStartTime;
  final TimeOfDay? workEndTime;
  final bool drinksCaffeine;
  final String? caffeineTiming;
  final TimeOfDay? caffeineTime;
  final String? chronotype;
  final Set<int> studyDays;
  final Set<String> selectedPackages;

  OnboardingState copyWith({
    int? step,
    TimeOfDay? wakeTime,
    TimeOfDay? sleepTime,
    TimeOfDay? workStartTime,
    TimeOfDay? workEndTime,
    bool? drinksCaffeine,
    String? caffeineTiming,
    TimeOfDay? caffeineTime,
    String? chronotype,
    Set<int>? studyDays,
    Set<String>? selectedPackages,
    bool clearWorkTimes = false,
    bool clearCaffeineTime = false,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      workStartTime: clearWorkTimes ? null : (workStartTime ?? this.workStartTime),
      workEndTime: clearWorkTimes ? null : (workEndTime ?? this.workEndTime),
      drinksCaffeine: drinksCaffeine ?? this.drinksCaffeine,
      caffeineTiming: caffeineTiming ?? this.caffeineTiming,
      caffeineTime: clearCaffeineTime ? null : (caffeineTime ?? this.caffeineTime),
      chronotype: chronotype ?? this.chronotype,
      studyDays: studyDays ?? this.studyDays,
      selectedPackages: selectedPackages ?? this.selectedPackages,
    );
  }

  bool get profileComplete =>
      wakeTime != null &&
      sleepTime != null &&
      (drinksCaffeine ? caffeineTiming != null : true) &&
      chronotype != null &&
      studyDays.isNotEmpty;
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => OnboardingState();

  void goToStep(int step) {
    state = state.copyWith(step: step);
  }

  void nextStep() {
    state = state.copyWith(step: state.step + 1);
  }

  void setWakeTime(TimeOfDay t) => state = state.copyWith(wakeTime: t);
  void setSleepTime(TimeOfDay t) => state = state.copyWith(sleepTime: t);
  void setWorkStartTime(TimeOfDay t) => state = state.copyWith(workStartTime: t);
  void setWorkEndTime(TimeOfDay t) => state = state.copyWith(workEndTime: t);
  void clearWorkTimes() => state = state.copyWith(clearWorkTimes: true);

  void setDrinksCaffeine(bool v) {
    state = state.copyWith(
      drinksCaffeine: v,
      clearCaffeineTime: !v,
      caffeineTiming: !v ? null : state.caffeineTiming,
      caffeineTime: !v ? null : state.caffeineTime,
    );
  }

  void setCaffeineTiming(String? v) => state = state.copyWith(caffeineTiming: v);
  void setCaffeineTime(TimeOfDay t) => state = state.copyWith(caffeineTime: t);
  void setChronotype(String? v) => state = state.copyWith(chronotype: v);

  void toggleStudyDay(int day) {
    final days = Set<int>.from(state.studyDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    state = state.copyWith(studyDays: days);
  }

  void togglePackage(String packageName) {
    final packages = Set<String>.from(state.selectedPackages);
    if (packages.contains(packageName)) {
      packages.remove(packageName);
    } else {
      packages.add(packageName);
    }
    state = state.copyWith(selectedPackages: packages);
  }

  Future<void> save() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final whitelistRepo = ref.read(whitelistRepositoryProvider);

    final now = DateTime.now().millisecondsSinceEpoch;
    String formatTime(TimeOfDay? t) => t == null
        ? ''
        : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final companion = UserProfilesCompanion.insert(
      id: 'default',
      wakeTime: formatTime(state.wakeTime),
      sleepTime: formatTime(state.sleepTime),
      workStartTime: Value(formatTime(state.workStartTime)),
      workEndTime: Value(formatTime(state.workEndTime)),
      drinksCaffeine: Value(state.drinksCaffeine),
      caffeineTiming: Value(state.caffeineTiming),
      caffeineTime: Value(formatTime(state.caffeineTime)),
      chronotype: Value(state.chronotype),
      studyDays: Value(
          profileRepo.encodeStudyDays(state.studyDays.toList()..sort())),
      onboardingCompletedAt: Value(now),
    );
    await profileRepo.upsert(companion);

    await whitelistRepo.replaceAll(
      state.selectedPackages
          .map((p) => AppWhitelistsCompanion.insert(packageName: p, appName: p))
          .toList(),
    );

    await ref.read(prefsServiceProvider).setOnboardingComplete();
    ref.invalidate(onboardingCompleteProvider);
    await ref.read(onboardingCompleteProvider.future);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);
