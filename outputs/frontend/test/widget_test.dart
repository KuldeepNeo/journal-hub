import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal_app/src/app.dart';

void main() {
  testWidgets('App navigation and rendering smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: JournalApp(),
      ),
    );

    // Allow GoRouter to resolve initial route (/login)
    await tester.pumpAndSettle();

    // Verify that the login screen placeholder is rendered
    expect(find.text('Journal Hub'), findsOneWidget);
    expect(find.text('Write your story, secure and private.'), findsOneWidget);
    expect(find.text('Enter Application'), findsOneWidget);

    // Tap the 'Enter Application' button
    await tester.tap(find.text('Enter Application'));
    
    // Animate transition and settle
    await tester.pumpAndSettle();

    // Verify we navigated to the home screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Your development workspace is initialized and ready.'), findsOneWidget);
  });
}
