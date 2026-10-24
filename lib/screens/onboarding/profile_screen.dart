import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/controllers/onboarding_controller.dart';
import 'package:study_app/utils/time_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay? current,
    ValueChanged<TimeOfDay> onSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your routine', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _TimeRow(
            label: 'Wake up time',
            value: state.wakeTime,
            onTap: () => _pickTime(context, state.wakeTime, controller.setWakeTime),
          ),
          _TimeRow(
            label: 'Sleep time',
            value: state.sleepTime,
            onTap: () => _pickTime(context, state.sleepTime, controller.setSleepTime),
          ),
          _TimeRow(
            label: 'Work/school start (optional)',
            value: state.workStartTime,
            onTap: () => _pickTime(context, state.workStartTime, controller.setWorkStartTime),
          ),
          _TimeRow(
            label: 'Work/school end (optional)',
            value: state.workEndTime,
            onTap: () => _pickTime(context, state.workEndTime, controller.setWorkEndTime),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Do you drink caffeine?'),
            value: state.drinksCaffeine,
            onChanged: controller.setDrinksCaffeine,
            contentPadding: EdgeInsets.zero,
          ),
          if (state.drinksCaffeine) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text('When do you usually drink it?',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Morning'),
                  selected: state.caffeineTiming == 'morning',
                  onSelected: (_) => controller.setCaffeineTiming('morning'),
                ),
                ChoiceChip(
                  label: const Text('Afternoon'),
                  selected: state.caffeineTiming == 'afternoon',
                  onSelected: (_) => controller.setCaffeineTiming('afternoon'),
                ),
                ChoiceChip(
                  label: const Text('Evening'),
                  selected: state.caffeineTiming == 'evening',
                  onSelected: (_) => controller.setCaffeineTiming('evening'),
                ),
                ChoiceChip(
                  label: const Text('Throughout day'),
                  selected: state.caffeineTiming == 'throughout',
                  onSelected: (_) => controller.setCaffeineTiming('throughout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _TimeRow(
              label: 'Typical caffeine time (optional)',
              value: state.caffeineTime,
              onTap: () => _pickTime(context, state.caffeineTime, controller.setCaffeineTime),
            ),
          ],
          const Divider(height: 32),
          Text('Your chronotype', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Early bird'),
                selected: state.chronotype == 'early_bird',
                onSelected: (_) => controller.setChronotype('early_bird'),
              ),
              ChoiceChip(
                label: const Text('Night owl'),
                selected: state.chronotype == 'night_owl',
                onSelected: (_) => controller.setChronotype('night_owl'),
              ),
              ChoiceChip(
                label: const Text('Regular'),
                selected: state.chronotype == 'regular',
                onSelected: (_) => controller.setChronotype('regular'),
              ),
            ],
          ),
          const Divider(height: 32),
          Text('Days you typically study', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              return FilterChip(
                label: Text(dayLabels[i]),
                selected: state.studyDays.contains(i),
                onSelected: (_) => controller.toggleStudyDay(i),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value, required this.onTap});

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        value != null ? formatTimeOfDay(value!) : '--:--',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: onTap,
    );
  }
}
