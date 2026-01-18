// Basic Flutter widget test for MirrorMe app

import 'package:flutter_test/flutter_test.dart';
import 'package:mirror_me/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MirrorMeApp());
    await tester.pump();

    // Verify that the app loads (splash screen or login)
    expect(find.byType(MirrorMeApp), findsOneWidget);
  });
}
