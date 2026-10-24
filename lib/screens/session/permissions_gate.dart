import 'package:flutter/material.dart';
import 'package:study_app/services/blocker_platform.dart';

class PermissionsGate extends StatefulWidget {
  const PermissionsGate({super.key, required this.child});

  final Widget child;

  @override
  State<PermissionsGate> createState() => _PermissionsGateState();
}

class _PermissionsGateState extends State<PermissionsGate>
    with WidgetsBindingObserver {
  bool _usageAccessGranted = false;
  bool _overlayEnabled = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final usageAccess = await BlockerPlatform.isUsageAccessGranted();
    final overlay = await BlockerPlatform.canDrawOverlays();
    if (mounted) {
      setState(() {
        _usageAccessGranted = usageAccess;
        _overlayEnabled = overlay;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_usageAccessGranted && _overlayEnabled) return widget.child;
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions Required')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'App blocking needs permissions',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'To block distracting apps, FocusFlow needs the Usage access and Display over other apps permissions.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!_usageAccessGranted)
              FilledButton(
                onPressed: () => BlockerPlatform.openUsageAccessSettings(),
                child: const Text('Allow Usage access'),
              ),
            if (!_overlayEnabled)
              FilledButton(
                onPressed: () => BlockerPlatform.openOverlaySettings(),
                child: const Text('Allow Overlay'),
              ),
          ],
        ),
      ),
    );
  }
}
