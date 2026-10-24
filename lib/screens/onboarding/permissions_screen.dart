import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/services/blocker_platform.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _usageAccessGranted = false;
  bool _overlayEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final usageAccess = await BlockerPlatform.isUsageAccessGranted();
    final overlay = await BlockerPlatform.canDrawOverlays();
    if (mounted) {
      setState(() {
        _usageAccessGranted = usageAccess;
        _overlayEnabled = overlay;
      });
    }
  }

  Future<void> _requestOverlay() async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
      );
      await intent.launch();
    } on PlatformException {
      const intent = AndroidIntent(action: 'android.settings.APP_NOTIFICATION_SETTINGS');
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _usageAccessGranted && _overlayEnabled;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Permissions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'FocusFlow needs these permissions to block distracting apps during your study sessions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _PermissionCard(
            icon: Icons.data_usage,
            title: 'Usage access',
            description:
                'Detects which app is in the foreground so FocusFlow can block non-whitelisted apps during your session.',
            granted: _usageAccessGranted,
            actionLabel: _usageAccessGranted ? 'Granted' : 'Open Settings',
            onPressed: () async {
              await BlockerPlatform.openUsageAccessSettings();
            },
          ),
          const SizedBox(height: 16),
          _PermissionCard(
            icon: Icons.layers,
            title: 'Display over other apps',
            description:
                'Allows FocusFlow to show a "blocked" overlay when you try to open a non-whitelisted app during a session.',
            granted: _overlayEnabled,
            actionLabel: _overlayEnabled ? 'Granted' : 'Open Settings',
            onPressed: _requestOverlay,
          ),
          const SizedBox(height: 24),
          if (allGranted)
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text('All permissions granted. You are ready to go!',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            )
          else
            Text(
              'Grant both permissions above to enable app blocking. '
              'You can also grant them later from Settings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                granted
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.circle_outlined, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            if (!granted)
              FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
