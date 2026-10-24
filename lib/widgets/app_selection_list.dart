import 'package:flutter/material.dart';
import 'package:study_app/services/apps_service.dart';
import 'package:study_app/widgets/app_icon.dart';

/// Searchable checkbox list of installed apps used by the onboarding
/// whitelist step and the post-onboarding whitelist editor.
class AppSelectionList extends StatelessWidget {
  const AppSelectionList({
    super.key,
    required this.apps,
    required this.query,
    required this.selected,
    required this.onToggle,
    this.emptyMessage,
  });

  final List<InstalledApp> apps;

  /// Lowercase search query; filters by app and package name.
  final String query;
  final Set<String> selected;
  final void Function(InstalledApp) onToggle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? apps
        : apps
            .where((a) =>
                a.appName.toLowerCase().contains(query) ||
                a.packageName.toLowerCase().contains(query))
            .toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ??
              (query.isEmpty ? 'No apps found.' : 'No apps match your search.'),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final app = filtered[index];
        final isSelected = selected.contains(app.packageName);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => onToggle(app),
          title: Text(app.appName),
          subtitle: Text(
            app.packageName,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          secondary: AppIcon(packageName: app.packageName),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
