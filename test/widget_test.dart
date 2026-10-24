import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FocusFlowApp()),
    );
    await tester.pump();
    // Basic smoke test: app should build without crashing
    expect(find.byType(FocusFlowApp), findsOneWidget);
  });
}
