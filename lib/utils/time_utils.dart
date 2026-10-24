import 'package:flutter/material.dart';

enum TimeBlock { morning, afternoon, evening, lateNight }

extension TimeBlockX on TimeBlock {
  String get label {
    switch (this) {
      case TimeBlock.morning:
        return 'Morning';
      case TimeBlock.afternoon:
        return 'Afternoon';
      case TimeBlock.evening:
        return 'Evening';
      case TimeBlock.lateNight:
        return 'Late Night';
    }
  }

  String get range {
    switch (this) {
      case TimeBlock.morning:
        return '06:00–11:59';
      case TimeBlock.afternoon:
        return '12:00–17:59';
      case TimeBlock.evening:
        return '18:00–23:59';
      case TimeBlock.lateNight:
        return '00:00–05:59';
    }
  }

  String get storageValue {
    switch (this) {
      case TimeBlock.morning:
        return 'morning';
      case TimeBlock.afternoon:
        return 'afternoon';
      case TimeBlock.evening:
        return 'evening';
      case TimeBlock.lateNight:
        return 'late_night';
    }
  }

  static TimeBlock fromHour(int hour) {
    if (hour >= 6 && hour < 12) return TimeBlock.morning;
    if (hour >= 12 && hour < 18) return TimeBlock.afternoon;
    if (hour >= 18 && hour < 24) return TimeBlock.evening;
    return TimeBlock.lateNight;
  }

  static TimeBlock fromStorage(String value) {
    switch (value) {
      case 'morning':
        return TimeBlock.morning;
      case 'afternoon':
        return TimeBlock.afternoon;
      case 'evening':
        return TimeBlock.evening;
      default:
        return TimeBlock.lateNight;
    }
  }
}

const List<String> dayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String dayLabel(int dayOfWeek) => dayLabels[dayOfWeek % 7];

String formatMinutes(double minutes) {
  final total = minutes.round();
  final h = total ~/ 60;
  final m = total % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:$mm:$ss';
  return '$mm:$ss';
}

String formatTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay parseTimeOfDay(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime timeOfDayToDate(TimeOfDay t, {DateTime? base}) {
  final b = base ?? DateTime.now();
  return DateTime(b.year, b.month, b.day, t.hour, t.minute);
}
