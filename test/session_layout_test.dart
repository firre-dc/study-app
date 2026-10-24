import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_app/controllers/session_controller.dart';
import 'package:study_app/screens/session/session_screen.dart';

class _ActiveSessionController extends SessionController {
  @override
  SessionControllerState build() => const SessionControllerState(
        state: SessionState.active,
        durationMinutes: 25,
        sessionId: 's1',
        remainingSeconds: 1500,
      );
}

void main() {
  testWidgets('session timer ring and countdown are centered on screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider
              .overrideWith(() => _ActiveSessionController()),
        ],
        child: const MaterialApp(home: SessionScreen()),
      ),
    );
    await tester.pump();

    final screen = tester.getRect(find.byType(Scaffold));
    final ring = tester.getRect(find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 240 && w.height == 240));
    final countdown = tester.getRect(find.text('25:00'));

    expect(ring.center.dx, closeTo(screen.center.dx, 1.0),
        reason: 'timer ring must be horizontally centered');
    expect(ring.center.dy, closeTo(screen.center.dy, 20.0),
        reason: 'timer ring must be vertically near center');
    expect(countdown.center.dx, closeTo(ring.center.dx, 1.0),
        reason: 'countdown text must be centered inside the ring');
    expect(countdown.center.dy, closeTo(ring.center.dy, 20.0),
        reason: 'countdown text must be centered inside the ring');
  });
}
